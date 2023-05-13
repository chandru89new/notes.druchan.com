module Main where

import Prelude
import Control.Monad.Except (ExceptT(..), runExceptT)
import Control.Parallel (parTraverse, parTraverse_)
import Data.Array (foldl, sortBy)
import Data.Either (Either(..))
import Data.String (Pattern(..), Replacement(..), replaceAll)
import Effect (Effect)
import Effect.Aff (Aff, Error, launchAff_, try)
import Effect.Class.Console (log)
import Node.Encoding (Encoding(..))
import Node.FS.Aff (readTextFile, readdir, writeTextFile)
import Utils (FormattedMarkdownData, archiveTemplate, blogpostTemplate, createFolderIfNotPresent, formatDate, md2FormattedData, rawContentsFolder, tmpFolder)

main :: Effect Unit
main =
  launchAff_
    $ do
        res <- runExceptT buildSite
        case res of
          Left err -> log $ show err
          Right _ -> log "Done."

newtype Template
  = Template String

readFileToData :: String -> ExceptT Error Aff FormattedMarkdownData
readFileToData filePath = do
  contents <- ExceptT $ try $ readTextFile UTF8 filePath
  pure $ md2FormattedData contents

writeHTMLFile :: Template -> FormattedMarkdownData -> ExceptT Error Aff Unit
writeHTMLFile template pd@{ frontMatter } =
  ExceptT
    $ do
        res <- try $ writeTextFile UTF8 (tmpFolder <> "/" <> frontMatter.slug <> ".html") (replaceContentInTemplate template pd)
        _ <- case res of
          Left err -> log $ "Could not write " <> frontMatter.slug <> ".md to html (" <> show err <> ")"
          Right _ -> log $ rawContentsFolder <> "/" <> frontMatter.slug <> ".md -> " <> tmpFolder <> "/" <> frontMatter.slug <> ".html" <> " = success!"
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

generatePostsHTML :: ExceptT Error Aff Unit
generatePostsHTML = do
  { files, template } <- getFilesAndTemplate
  _ <- createFolderIfNotPresent tmpFolder
  _ <- parTraverse_ (\f -> readAndWriteHTMLFile (Template template) $ rawContentsFolder <> "/" <> f) files
  pure unit

replaceContentInTemplate :: Template -> FormattedMarkdownData -> String
replaceContentInTemplate (Template template) pd =
  replaceAll (Pattern "{{title}}") (Replacement pd.frontMatter.title) template
    # replaceAll (Pattern "{{content}}") (Replacement $ augmentATags pd.content)
    # replaceAll (Pattern "{{date}}") (Replacement $ formatDate "MMM DD, YYYY" pd.frontMatter.date)
  where
  augmentATags :: String -> String
  augmentATags = replaceAll (Pattern "<a") (Replacement "<a target='_blank'")

readPostTemplate :: ExceptT Error Aff String
readPostTemplate = ExceptT $ try $ readTextFile UTF8 blogpostTemplate

buildSite :: ExceptT Error Aff Unit
buildSite = do
  log "\nStarting..."
  log "\nGenerating posts pages..."
  postGenerationResult <- generatePostsHTML
  log "\nGenerated posts pages: Done!"
  log "\nGenerating archive page..."
  _ <- createFullArchivePage
  log "\nGenerating archive page: Done!"
  log "\nGenerating home page: Done!"
  log "\nGenerating home page: Done!"

createFullArchivePage :: ExceptT Error Aff Unit
createFullArchivePage = do
  filePaths <- ExceptT $ try $ readdir rawContentsFolder
  formattedDataArray <- filePathsToProcessedData filePaths
  sortedArray <- pure $ sortArray formattedDataArray
  content <- (toHTML sortedArray)
  writeFullArchivePage content
  where
  filePathsToProcessedData :: Array String -> ExceptT Error Aff (Array FormattedMarkdownData)
  filePathsToProcessedData fpaths = parTraverse (\f -> readFileToData $ rawContentsFolder <> "/" <> f) fpaths

  sortArray :: Array FormattedMarkdownData -> Array FormattedMarkdownData
  sortArray = sortBy (\a b -> if a.frontMatter.date < b.frontMatter.date then GT else LT)

  toHTML :: Array FormattedMarkdownData -> ExceptT Error Aff String
  toHTML fd = do
    template <- ExceptT $ try $ readTextFile UTF8 archiveTemplate
    pure $ replaceAll (Pattern "{{content}}") (Replacement $ "<ul>" <> content <> "</ul>") template
    where
    content = foldl fn "" fd

    fn b a = b <> "<li><a href='./" <> a.frontMatter.slug <> ".html'>" <> a.frontMatter.title <> " (" <> formatDate "MMM DD, YYYY" a.frontMatter.date <> ")" <> "</a></li>"

  writeFullArchivePage :: String -> ExceptT Error Aff Unit
  writeFullArchivePage str = ExceptT $ try $ writeTextFile UTF8 "./tmp/archive.html" str
