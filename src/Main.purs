module Main where

import Prelude

import Control.Monad.Except (ExceptT(..), runExceptT)
import Control.Parallel (parTraverse_)
import Data.Either (Either(..))
import Data.String (Pattern(..), Replacement(..), replaceAll)
import Effect (Effect)
import Effect.Aff (Aff, Error, launchAff_, try)
import Effect.Class.Console (log)
import Node.Encoding (Encoding(..))
import Node.FS.Aff (readTextFile, readdir, writeTextFile)
import Utils (blogpostTemplate, createFolderIfNotPresent, htmlOutputFolder, rawContentsFolder)

foreign import md2Html :: String -> FormattedMarkdownData

type ParsedMarkdownData
  = { frontMatter :: { title :: String, date :: String, slug :: String }, content :: String }

type FormattedMarkdownData
  = { frontMatter :: { title :: String, date :: String, slug :: String }
    , content :: String
    }

newtype Template
  = Template String

readFileToData :: String -> ExceptT Error Aff FormattedMarkdownData
readFileToData filePath = do
  contents <- ExceptT $ try $ readTextFile UTF8 filePath
  pure $ md2Html contents
  -- where
  -- formatProcessedData :: ParsedMarkdownData -> Effect FormattedMarkdownData
  -- formatProcessedData raw = do
  --   dateString <- parse raw.frontMatter.date
  --   pure $ raw { frontMatter = raw.frontMatter { date = dateString } }

writeHTMLFile :: Template -> FormattedMarkdownData -> ExceptT Error Aff Unit
writeHTMLFile template pd@{ frontMatter } =
  ExceptT
    $ do
        res <- try $ writeTextFile UTF8 (htmlOutputFolder <> "/" <> frontMatter.slug <> ".html") (replaceContentInTemplate template pd)
        _ <- case res of
          Left err -> log $ "Could not write " <> frontMatter.slug <> ".md to html (" <> show err <> ")"
          Right _ -> log $ frontMatter.slug <> ".md -> " <> htmlOutputFolder <> "/" <> pd.frontMatter.slug <> ".html" <> " = success!"
        pure res

readAndWriteHTMLFile :: Template -> String -> ExceptT Error Aff Unit
readAndWriteHTMLFile template filePath = do
  pd <- readFileToData filePath
  writeHTMLFile template pd

getFilesAndTemplate :: ExceptT Error Aff { files :: Array String, template :: String }
getFilesAndTemplate = do
  files <- ExceptT $ try $ readdir rawContentsFolder
  template <- readPostTemplate
  pure { files, template }

generateHTMLFiles :: Effect Unit
generateHTMLFiles =
  launchAff_
    $ do
        result <- runExceptT getFilesAndTemplate
        ensureOutputFolder <- runExceptT (createFolderIfNotPresent htmlOutputFolder)
        log $ show ensureOutputFolder
        case result, ensureOutputFolder of
          Right { files, template }, Right _ -> parTraverse_ (\f -> runExceptT $ readAndWriteHTMLFile (Template template) $ rawContentsFolder <> "/" <> f) files
          Left err, _ -> log $ show err
          _, Left err -> log $ show err
        log "Done."

replaceContentInTemplate :: Template -> FormattedMarkdownData -> String
replaceContentInTemplate (Template template) pd =
  replaceAll (Pattern "{{title}}") (Replacement pd.frontMatter.title) template
    # replaceAll (Pattern "{{content}}") (Replacement pd.content)
    # replaceAll (Pattern "{{date}}") (Replacement $ formatDate "MMM DD, YYYY"  pd.frontMatter.date)

readPostTemplate :: ExceptT Error Aff String
readPostTemplate = ExceptT $ try $ readTextFile UTF8 blogpostTemplate


foreign import formatDate :: String -> String -> String 