module Utils where

import Prelude
import Control.Monad.Except (ExceptT(..))
import Data.Either (Either(..))
import Effect.Aff (Aff, Error, try)
import Node.FS.Aff (mkdir, readdir)

templatesFolder :: String
templatesFolder = "./templates"

htmlOutputFolder :: String
htmlOutputFolder = "./public"

rawContentsFolder :: String
rawContentsFolder = "./contents"

blogpostTemplate :: String
blogpostTemplate = templatesFolder <> "/post.html"

tmpFolder :: String
tmpFolder = "./tmp"

archiveTemplate :: String
archiveTemplate = templatesFolder <> "/archive.html"

createFolderIfNotPresent :: String -> ExceptT Error Aff Unit
createFolderIfNotPresent folderName =
  ExceptT
    $ do
        res <- try $ readdir folderName
        case res of
          Right _ -> pure $ Right unit
          Left _ -> try $ mkdir folderName

foreign import formatDate :: String -> String -> String

type ParsedMarkdownData
  = { frontMatter :: { title :: String, date :: String, slug :: String }, content :: String }

type FormattedMarkdownData
  = { frontMatter :: { title :: String, date :: String, slug :: String }
    , content :: String
    }

foreign import md2FormattedData :: String -> FormattedMarkdownData

foreign import htmlToMarkdown :: String -> String

foreign import getEnv :: String -> String
