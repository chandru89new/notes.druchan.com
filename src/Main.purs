module Main where

import Prelude
import Control.Monad.Except (ExceptT(..), runExceptT)
import Control.Parallel (parTraverse, parTraverse_)
import Data.Array (catMaybes, filter, find, foldl, sortBy, take)
import Data.Either (Either(..))
import Data.String (Pattern(..), Replacement(..), contains, replaceAll)
import Effect (Effect)
import Effect.Aff (Aff, Error, launchAff_, try)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Node.Buffer (Buffer)
import Node.ChildProcess (defaultExecSyncOptions, execSync)
import Node.Encoding (Encoding(..))
import Node.FS.Aff (readTextFile, readdir, writeTextFile)
import Utils (FormattedMarkdownData, archiveTemplate, blogpostTemplate, createFolderIfNotPresent, formatDate, getCategoriesJson, homepageTemplate, htmlOutputFolder, md2FormattedData, rawContentsFolder, templatesFolder, tmpFolder)
import Utils as U

main :: Effect Unit
main =
  launchAff_
    $ do
        res <- runExceptT buildSite
        case res of
          Left err -> do
            _ <- liftEffect $ execSync "rm -rf ./tmp" defaultExecSyncOptions
            log $ show err
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

getFilesAndTemplate :: ExceptT Error Aff { files :: Array String, template :: String }
getFilesAndTemplate = do
  files <- ExceptT $ try $ readdir rawContentsFolder
  template <- readPostTemplate
  pure { files, template }

generatePostsHTML :: Array FormattedMarkdownData -> ExceptT Error Aff Unit
generatePostsHTML fds = do
  template <- readPostTemplate
  _ <- parTraverse_ (\f -> writeHTMLFile (Template template) f) fds
  pure unit

replaceContentInTemplate :: Template -> FormattedMarkdownData -> String
replaceContentInTemplate (Template template) pd =
  replaceAll (Pattern "{{title}}") (Replacement $ "<a href=\"./" <> pd.frontMatter.slug <> "\">" <> pd.frontMatter.title <> "</a>") template
    # replaceAll (Pattern "{{content}}") (Replacement $ augmentATags pd.content)
    # replaceAll (Pattern "{{date}}") (Replacement $ formatDate "MMM DD, YYYY" pd.frontMatter.date)
    # replaceAll (Pattern "{{page_title}}") (Replacement pd.frontMatter.title)
  where
  augmentATags :: String -> String
  augmentATags = replaceAll (Pattern "<a") (Replacement "<a target='_blank'")

readPostTemplate :: ExceptT Error Aff String
readPostTemplate = ExceptT $ try $ readTextFile UTF8 blogpostTemplate

buildSite :: ExceptT Error Aff Unit
buildSite = do
  log "\nStarting..."
  _ <- createFolderIfNotPresent tmpFolder
  sortedPosts <- getPostsAndSort
  log "\nGenerating posts pages..."
  _ <- generatePostsHTML sortedPosts
  log "\nGenerating posts pages: Done!"
  log "\nGenerating archive page..."
  _ <- createFullArchivePage sortedPosts
  log "\nGenerating archive page: Done!"
  log "\nGenerating home page..."
  _ <- createHomePage sortedPosts
  log "\nGenerating home page: Done!"
  log "\nCopying 404.html..."
  _ <- ExceptT $ try $ liftEffect $ execSync ("cp " <> templatesFolder <> "/404.html " <> tmpFolder) defaultExecSyncOptions
  log "\nCopying 404.html: Done!"
  log "\nCopying images folder..."
  _ <- ExceptT $ try $ liftEffect $ execSync ("cp -r " <> templatesFolder <> "/images " <> tmpFolder) defaultExecSyncOptions
  log "\nCopying images folder: Done!"
  log "\nCopying js folder..."
  _ <- ExceptT $ try $ liftEffect $ execSync ("cp -r " <> templatesFolder <> "/js " <> tmpFolder) defaultExecSyncOptions
  log "\nCopying js folder: Done!"
  log "\nGenerating styles.css..."
  _ <- generateStyles
  log "\nGenerating styles.css: Done!"
  log "\nCopying /tmp to /public"
  _ <- createFolderIfNotPresent htmlOutputFolder
  _ <- ExceptT $ try $ liftEffect $ execSync "cp -r ./tmp/* ./public" defaultExecSyncOptions
  log "\nCopying /tmp to /public: Done!"
  log "\nCleaning up..."
  _ <- ExceptT $ try $ liftEffect $ execSync "rm -rf ./tmp" defaultExecSyncOptions
  log "\nCleaning up: Done!"

createFullArchivePage :: Array FormattedMarkdownData -> ExceptT Error Aff Unit
createFullArchivePage sortedArray = do
  content <- (toHTML sortedArray)
  writeFullArchivePage content
  where
  toHTML :: Array FormattedMarkdownData -> ExceptT Error Aff String
  toHTML fd = do
    template <- ExceptT $ try $ readTextFile UTF8 archiveTemplate
    pure $ replaceAll (Pattern "{{content}}") (Replacement $ "<ul>" <> content <> "</ul>") template
    where
    content = foldl fn "" fd

    fn b a = b <> "<li><a href=\"./" <> a.frontMatter.slug <> "\">" <> a.frontMatter.title <> "</a> &mdash; <span class=\"date\">" <> formatDate "MMM DD, YYYY" a.frontMatter.date <> "</span>" <> "</li>"

  writeFullArchivePage :: String -> ExceptT Error Aff Unit
  writeFullArchivePage str = ExceptT $ try $ writeTextFile UTF8 "./tmp/archive.html" str

generateStyles :: ExceptT Error Aff Buffer
generateStyles =
  ExceptT
    $ try
    $ liftEffect
    $ execSync command defaultExecSyncOptions
  where
  command = "npx tailwindcss -i " <> templatesFolder <> "/style.css -o " <> tmpFolder <> "/style.css"

recentPosts :: Int -> Array FormattedMarkdownData -> String
recentPosts n xs =
  let
    recentN = take n xs
  in
    case recentN of
      [] -> "Nothing here."
      ys -> renderRecents ys
        where
        renderRecents fds = "<ul>" <> foldl fn "" fds <> "</ul>"

        fn b a = b <> "<li><a href=\"/" <> a.frontMatter.slug <> "\">" <> a.frontMatter.title <> "</a> &mdash; <span class=\"date\">" <> formatDate "MMM DD, YYYY" a.frontMatter.date <> "</span>" <> "</li>"

createHomePage :: Array FormattedMarkdownData -> ExceptT Error Aff Unit
createHomePage sortedArrayofPosts = do
  recentsString <- pure $ recentPosts 5 sortedArrayofPosts
  template <- ExceptT $ try $ readTextFile UTF8 homepageTemplate
  categories <- pure $ (getCategoriesJson unit # convertCategoriesToString)
  contents <-
    pure
      $ replaceAll (Pattern "{{recent_posts}}") (Replacement recentsString) template
      # replaceAll (Pattern "{{posts_by_categories}}") (Replacement categories)
  ExceptT $ try $ writeTextFile UTF8 (tmpFolder <> "/index.html") contents
  where
  convertCategoriesToString :: Array U.Category -> String
  convertCategoriesToString = foldl fn ""

  fn b a = b <> "<section><h3 class=\"category\">" <> a.category <> "</h3><ul>" <> renderPosts a.posts <> "</ul></section>"

  renderPosts :: Array String -> String
  renderPosts posts = foldl fn2 "" (filteredPosts posts)

  filteredPosts :: Array String -> Array FormattedMarkdownData
  filteredPosts xs =
    map
      ( \x ->
          find (\p -> p.frontMatter.slug == x) sortedArrayofPosts
      )
      xs
      # catMaybes
      # sortPosts

  fn2 b a = b <> "<li><a href=\"./" <> a.frontMatter.slug <> "\">" <> a.frontMatter.title <> "</a> &mdash; <span class=\"date\">" <> formatDate "MMM DD, YYYY" a.frontMatter.date <> "</span></li>"

getPostsAndSort :: ExceptT Error Aff (Array FormattedMarkdownData)
getPostsAndSort = do
  filePaths <- ExceptT $ try $ readdir rawContentsFolder
  onlyMarkdownFiles <- pure $ filter (contains (Pattern ".md")) filePaths
  formattedDataArray <- filePathsToProcessedData onlyMarkdownFiles
  removeIgnored <- pure $ filter (\f -> not f.frontMatter.ignore) formattedDataArray
  pure $ sortPosts removeIgnored
  where
  filePathsToProcessedData :: Array String -> ExceptT Error Aff (Array FormattedMarkdownData)
  filePathsToProcessedData fpaths = parTraverse (\f -> readFileToData $ rawContentsFolder <> "/" <> f) fpaths

sortPosts :: Array FormattedMarkdownData -> Array FormattedMarkdownData
sortPosts = sortBy (\a b -> if a.frontMatter.date < b.frontMatter.date then GT else LT)
