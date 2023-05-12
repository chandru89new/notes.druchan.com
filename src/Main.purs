module Main where

{-
To run:
- make sure there is a `contents` folder at the top-level
- set Tumblr API_KEY in the env. ie, export API_KEY=.... (consult Obsidian for this)
- then `spago repl`
- `import Main`
- `main' 0` (or main' 10 or 20 ...) the int is offset 
- check `contents` folder for the files.

To generate static html from contents folder, start spago repl and import Main and:
- generateHTMLFiles
-}
import Prelude
import Control.Parallel (parTraverse_)
import Data.Argonaut.Decode (fromJsonString)
import Data.Either (Either(..), either)
import Data.JSDate (JSDate, parse, toDateString)
import Data.List (List)
import Data.String (Pattern(..), Replacement(..), replaceAll)
import Effect (Effect)
import Effect.Aff (Aff, Error, launchAff_, try)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Fetch (Response, fetch)
import Node.Encoding (Encoding(..))
import Node.FS.Aff (readTextFile, readdir, writeTextFile)

main :: Effect Unit
main =
  launchAff_
    $ do
        res <- fetchAndDecode 0 1
        log $ show res

type FileData
  = { date :: String, title :: String, contents :: String, slug :: String }

writeDataToFile' :: FileData -> Aff Unit
writeDataToFile' fd@{ slug } = do
  writeTextFile UTF8 ("./contents/" <> slug <> ".md") (fileDataToMarkdown fd)

getPostsFromTumblr :: Int -> Int -> Aff Response
getPostsFromTumblr offset limit = fetch (requestURL <> "&limit=" <> show limit <> "&offset=" <> show offset) { "headers": { "Accept": "application/json" } }

requestURL :: String
requestURL = "https://api.tumblr.com/v2/blog/notesfromdruchan.tumblr.com/posts/text?api_key=" <> getEnv "API_KEY"

type APIResponse
  = { response ::
        { posts :: List { summary :: String, slug :: String, body :: String, date :: String }
        }
    }

fetchAndDecode :: Int -> Int -> Aff (Either String (List FileData))
fetchAndDecode offset limit = do
  { text } <- getPostsFromTumblr offset limit
  t <- text
  pure $ fromJsonString t # either (show >>> Left) (extractPosts >>> Right)

extractPosts :: APIResponse -> List FileData
extractPosts = map extractPost <<< _.response.posts

extractPost :: { date :: String, summary :: String, slug :: String, body :: String } -> FileData
extractPost { summary, slug, body, date } = { title: summary, slug, contents: body, date }

main' :: Int -> Effect Unit
main' offset =
  launchAff_
    $ do
        res <- fetchAndDecode offset 100
        case res of
          Left err -> log err
          Right fds -> parTraverse_ writeDataToFile' fds

foreign import htmlToMarkdown :: String -> String

fileDataToMarkdown :: FileData -> String
fileDataToMarkdown { title, contents, date, slug } =
  "---\n"
    <> "title: \'"
    <> title
    <> "\'\n"
    <> "date: \'"
    <> date
    <> "\'\n"
    <> "slug: "
    <> slug
    <> "\n"
    <> "---\n"
    <> htmlToMarkdown contents

foreign import getEnv :: String -> String

foreign import md2Html :: String -> ParsedMarkdownData

type ParsedMarkdownData
  = { frontMatter :: { title :: String, date :: String, slug :: String }, content :: String }

type FormattedMarkdownData
  = { frontMatter :: { title :: String, date :: JSDate, slug :: String }
    , content :: String
    }

mockMd :: String
mockMd =
  """---
title: Time to retire this
date: 2016-10-27 11:45:51 GMT
slug: time-to-retire-this
---
# h1

```js
Product people swear by the old, hacker-code-worthy _if it’s stupid and works, it’s not stupid_ thing. Even today.
```

"""

newtype Template
  = Template String

readFileToData :: String -> Aff FormattedMarkdownData
readFileToData filePath = do
  contents <- readTextFile UTF8 filePath
  liftEffect $ formatProcessedData (md2Html contents)
  where
  formatProcessedData :: ParsedMarkdownData -> Effect FormattedMarkdownData
  formatProcessedData raw = do
    dateString <- parse raw.frontMatter.date
    pure $ raw { frontMatter = raw.frontMatter { date = dateString } }

writeHTMLFile :: Template -> FormattedMarkdownData -> Aff (Either Error Unit)
writeHTMLFile template pd@{ frontMatter } = try $ writeTextFile UTF8 ("./dist/" <> frontMatter.slug <> ".html") (replaceContentInTemplate template pd)

readAndWriteHTMLFile :: Template -> String -> Aff Unit
readAndWriteHTMLFile template filePath = do
  pd <- readFileToData filePath
  didWrite <- writeHTMLFile template pd
  case didWrite of
    Right _ -> log $ filePath <> " -> " <> "./dist/" <> pd.frontMatter.slug <> ".html" <> " = success!"
    Left err -> log $ "Could not write " <> filePath <> " to html (" <> show err <> ")"

generateHTMLFiles :: Effect Unit
generateHTMLFiles =
  launchAff_
    $ do
        eitherFiles <- try $ readdir "./contents"
        eitherTemplate <- try $ readPostTemplate
        case eitherFiles, eitherTemplate of
          Right files, Right template -> parTraverse_ (\f -> readAndWriteHTMLFile (Template template) $ "./contents/" <> f) files
          Left err, _ -> log $ show err
          _, Left err -> log $ show err
        log "Done."

replaceContentInTemplate :: Template -> FormattedMarkdownData -> String
replaceContentInTemplate (Template template) pd =
  replaceAll (Pattern "{{title}}") (Replacement pd.frontMatter.title) template
    # replaceAll (Pattern "{{content}}") (Replacement pd.content)
    # replaceAll (Pattern "{{date}}") (Replacement $ toDateString pd.frontMatter.date)

readPostTemplate :: Aff String
readPostTemplate = readTextFile UTF8 "./templates/post.html"
