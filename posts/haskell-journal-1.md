---
title: Haskell Journal
date: 2024-11-27
slug: haskell-journal-1
collections: Functional programming, Project journal
---

- [Day 1](#day-1) - _Oct 7, 2024_
- [Day 2](#day-2) - _Oct 8, 2024_
- [Day 3](#day-3) - _Oct 9, 2024_
- [Day 4](#day-4) - _Oct 10, 2024_
- [Day 5](#day-5) - _Oct 11, 2024_
- [Day 6](#day-6) - _Oct 12, 2024_
- [Day 7](#day-7) - _Oct 13, 2024_
- [Day 8](#day-8) - _Oct 14, 2024_
- [Day 9](#day-9) - _Oct 15, 2024_
- [Day 10](#day-10) - _Oct 16, 2024_
- [Day 11](#day-11) - _Oct 17, 2024_
- [Day 12](#day-12) - _Oct 18, 2024_
- [Day 13](#day-13) - _Oct 21, 2024_
- [Day 14](#day-14) - _Oct 25, 2024_
- [Day 15](#day-15) - _Nov 4, 2024_
- [Day 16](#day-16) - _Nov 27, 2024_

###### Day 1

- Decided to finally build something in Haskell to learn the language. So far, I've been solving puzzles and similar tasks, but nothing has given me the confidence to say, "Yes, I can build that in Haskell."
- Areas to focus on:
  - File I/O
  - Making API calls to some service and processing data
  - Web scraping
  - Running a web server
  - Interacting with a database
  - Concurrency
- A recent problem I faced: YouTube's UI doesn't expose RSS feeds for channels, but it's present in the HTML source code. The idea: a CLI tool that takes a YouTube channel URL, scrapes the HTML source, and returns the feed link.
- Asked ChatGPT for a good web scraping library in Haskell. It suggested `tagsoup` and `html-conduit` (for fetching the source). Took a look at the examples and docs... seemed a little hard to grasp. Asked ChatGPT for a simpler alternative, and it suggested `scalpel`. Liked it, and decided to use it.
- Wrote some initial code based on ChatGPT's example of scraping. However, ChatGPT got the `attr` function wrong. There was some wrangling between `ScraperT` and `Scraper`, and I finally learned that I could use the `Identity` monad to go from `ScraperT` to `Scraper`. (Monad Transformers).
- Also experimented with constructing a scraper from a selector and then using it in the `scrapeURL` function.
- It took me a while to get an intuition for how the selectors and scrapers fit together, and then using the scraper in the scrape runners. I also felt uneasy when trying to "compose" a scraper from other scrapers (almost thought it was impossible).
  - I hit this issue because I needed to scrape the whole source but pick multiple data points—title of the channel and feed link URL—which were in different tags.
  - The solution was to use `optional`.
  - Eventually, I didn’t need this.
- The final piece of the puzzle was running this as a CLI tool, meaning I needed to take an argument (the YouTube channel's URL). ChatGPT suggested `optparse-applicative`, but I decided it was overkill for what I needed. A simple `--url <url>` argument was enough. ChatGPT suggested pattern matching on the arguments:

```haskell
case args of
  ("--url" : url : _) -> ...
  _ -> ...
```

- I tried to initialize the project with Stack first, but it threw some weird errors. So I decided to go with a Cabal-only approach, which worked. I haven’t investigated why Stack failed. I might not do that for now, as the Cabal setup seems good enough—I was able to add packages, build the binary, test it, and also run the REPL from Cabal.
- Overall, a great day 1—just the right amount of pushing against my comfort zone.

###### Day 2

- The tool initially handled a single URL and returned the feed link, but I needed it to work with multiple URLs since I had a lot of YouTube channels whose RSS feed links I wanted.
- The easy solution: pass a file to the tool, where the file contains one YouTube channel link per line. The code would then process each link, fetch the feed link, and finally write all the results to another file.
- This was straightforward to implement—I simply used `mapM` over the existing function that scraped and extracted the feed link.
- I asked ChatGPT if there was a more efficient, concurrent way to perform the mapping instead of `mapM`, and it suggested `mapConcurrently` from the `async` library. I added it and tested the execution times. However, there wasn't much difference between `mapM` and `mapConcurrently`. I suspect I might not be using it optimally.
- I spent some time experimenting with extracting additional data (such as the channel title, avatar, etc.), but I ultimately decided to stick to just extracting the feed link since this was intended to be a one-time operation.
- I realized that I wasn't handling file I/O errors properly when reading the list of URLs or writing the feed links. The code was just performing `IO a`, which could crash if there was an issue (e.g., an invalid file path). I decided to look into using `try` from `Control.Exception`—something I had used before in Purescript.
- I struggled with how to handle the exceptions and where to handle them. The types were now `IO (Either SomeException a)`, and I had to write several pattern matches (inside `do` blocks) for the `Left` and `Right` cases of the `Either`. I asked ChatGPT for ways to reduce this boilerplate, and it suggested using the `either` function, which wasn't as helpful as I hoped. I decided to revisit this later.
- I tend to trip up when dealing with `IO (Either ...)` types because I can't always tell where the code is in the `IO` context versus the `Either` context. My current approach involves trying every combination until the compiler stops complaining.
- After setting up the functions and testing them, I could finally implement the final feature—getting the tool to accept a `--path` parameter instead of a `--url`. This involved adding another pattern match in the code for `("--url" : url : _)`, but also required differentiating between a URL and a file path. A custom `data` type for the arguments helped here.
- Day 2 was interesting—it made me realize that I need to build error handling into my data types and functions from the start. The `IO (Either e a)` type is not ideal; I need an abstraction over it. The tool can now handle both single URLs and a file path containing multiple URLs, and it writes the feed links to a file.

###### Day 3

- I reflected on the project so far—it fetches RSS links for all the channels I'm subscribed to. But I could pivot and make this into a tool that works more like an RSS feed reader, or better yet, a way for me to get a "daily digest" from all the websites I want to track (using their RSS feeds).
- This idea sounds great because it allows me to play with databases as well. I'd have to store the data in a DB (leaning towards SQLite), and then fetch the "daily digest" data from there.
- This meant I needed to parse XML from RSS feeds and extract at least the following: **title**, **original link of the post**, and **published or updated date**.
- After looking around, I found **TagSoup** to be the best option (Scalpel didn't seem like the right fit since it's more focused on HTML than XML).
- I asked ChatGPT for an introduction to **TagSoup**, which gave me an idea of the main functions to use. Armed with this info, I dove into the documentation and found a few more helpful bits.
- It took a few tries to get things right. I created a dummy XML file to test on, and I had to extract the title, link, and updated date. **TagSoup** has some nice operators and combinators. After about an hour, I managed to extract all feed items from the given XML (though now I realize it's specific to YouTube's RSS feed—other feeds have different tags for their items… this will be another problem to solve).
- The tool has now morphed—it no longer extracts feed links from YouTube channel URLs. I removed that functionality since it was a one-time need for me (specific to YouTube channel feeds).
- I'm now thinking of refocusing the tool to perform tasks like:
  - Adding a feed to the database (`./app --add-feed <feed_url> --other-args`).
  - Running and fetching the daily digest (`./app digest`).
  - Managing the feeds stored in the DB with additional commands.
- Another thought: I used **Scalpel** for extracting info from YouTube subscriptions and for fetching the RSS feed link. I could potentially use **TagSoup** and **html-conduit** to replace these tasks and remove **Scalpel** as a dependency. However, since the YouTube-specific code is likely one-time use, this might not be necessary.
- Another discovery today, though I haven't fully explored it, is the use of **EitherT** and **ExceptT** monad transformers, which could simplify handling `IO (Either e a)` types. I had used these in my PureScript project (which manages my blog) but had forgotten about them. I asked ChatGPT, and it reminded me of monad transformers.
- Day 3 has opened up a lot of new possibilities for coding!

###### Day 4

- A couple of big wins today.
- The big-ticket item: I managed to port most functions to `ExceptT`, so now I don't have to wrestle with the `IO (Either e a)` datatype with pattern matching or bifunctor wrangling. Most functions involving side effects are now just `ExceptT SomeException IO a`—I can use them as if they yield the happy-path result. At some point, a `main` function will run `runExceptT`, and I can handle the errors there.
- Another big-ticket item: I got a handle (no pun intended) on integrating SQLite into my project and was able to write into one of the tables. All exploratory, but it worked—I wrote data into the DB from a Haskell function, and it landed safely in the SQLite file. I also started thinking about the table schema, but I haven't spent enough time on that yet.
- Since it's still early, I haven't thought about managing the database and changes—so no migrations yet. I just nuke the database when I need to change the columns or table structure.
- I was happy that if a table has a `TEXT` column (with a `NOT NULL` constraint), passing a `Just String` value inserts the `String` into the column, but passing `Nothing` throws an error at the DB layer.
- With the database integrated, two new problems arose: every function interfacing with the DB has to open and close the connection, and passing the connection around is redundant and ugly. I knew I'd eventually have to dip my toes into the `ReaderT` monad... turns out I'll have to do that soon.
- To wrap up the day, I chatted with ChatGPT to check some examples on how to combine `ReaderT` (to pass global config, like the DB connection) and `ExceptT` to handle errors gracefully. The examples were simple enough, so I have my work cut out for the next day on this project.

###### Day 5

- Quite possibly one of the worst days in the project so far.
- At first, I set up the app to be an `AppM` monad that was basically a `ReaderT config (ExceptT SomeException IO) a` — continuing from the idea from [day 4](/haskell-day-4). It was interesting and somewhat simple to execute because I had backing code from ChatGPT, and a fairly decent understanding of what was happening with the `runApp` mechanics. I had a `runApp` function that took a function of type `AppM a`, and then just ran it by passing it config like so:

```haskell
runApp :: AppM a -> IO (Either e a)
runApp app = do
	config <- ask -- gets the global app config
	runExceptT $ (runReaderT app config)
	-- runReaderT runs the app and extracts the inner monad (ExceptT e a)
	-- runExceptT then runs the inner monad and returns an IO (Either e a)
```

- Problems started brewing because all my lower-level functions were of the `ExceptT` type. At some point, the way I was doing it, running the app returned something like `IO (Either SomeException (Either SomeException ()))` — i.e., I was not passing the ExceptT context correctly.
- This had disastrous effects: errors were not being bubbled up (in my mind, that was the whole point of wrapping the app in the ExceptT monad). Instead, they were wrapped in another Either monad surrounded by the IO. Horrible. I had output that looked like this:

```haskell
Right (Left <some_error_message>)
```

- I had a long chat with ChatGPT about these things, asking it about the idea of bubbling up the errors from ExceptT without having to do `runExceptT` wherever I wanted the error to be bubbled up but the ideas it returned were not working or not useful — or in some cases, it was just reinventing the ExceptT or ReaderT monad transformers.
- But it did tell me how to actually unwrap the ExceptTs at lower-levels (using `runExceptT` of course), and then lift them in the `AppM` monad so that the exceptions bubble up and are caught at the top-most function — which is exactly what I want but not at the cost of having to run `runExceptT`s at the inner functions and then lifting them using custom lift functions.
- I had working code that did involve `runExceptT` and an interesting custom `liftEitherAppM` function:

```haskell
liftEitherAppM :: Either SomeException a -> AppM a
liftEitherAppM = either throwE return . lift
```

- As you can imagine, I spent all this time trying to understand some higher-level mechanics of the app (i.e. abstraction) rather than just working on the actual functionality and it was too late by the time I realized what I was doing.
- One other interesting thing that I noticed was that I did not google for solutions or ideas for a long time; it was almost at the end that I realized I could also just google/SO for solutions. That didn't help though. Ended up posting my questions on the FP slack.

Update: In the morning, I had the idea of looking at opensource Haskell projects to see what patterns they use. I tried Hakyll and PostgREST: both the projects seem to be just passing config to the relevant functions, so I think I will simplify the app for now to just pass `Config` (the one that has connection pool so that my inner functions that deal with DB can get a connection to work with) to the functions instead of using the `ReaderT` monad transformer until I get some more ideas and understanding of the monad.

###### Day 6

- Managed to remove the complexities of the `ReaderT` thingy with the app and introduced a much simpler type:

```haskell
type App a = Config -> ExceptT AppError IO a
```

- So now, any function that needs the config can simply be a function that takes a `Config` and returns an `ExceptT AppError IO a`.
- I also updated the feed-item extracting part of the code so that it can, in one pass, work for both Youtube feeds and other RSS XML 2.0 spec feeds — the difference in YT feeds is that they use `<link href="..." />` instead of `<link>{actual_url}</link>`, and they use `<published>` and `<updated>` instead of `<pubDate>`.. basically different specs. The way I handled this was to use the wonderful `<|>` (alternative) operator. My use-case has been very simple so far thankfully — I just try to extract/parse (using `tagsoup`) and then return a `Maybe String`. Combined with the `<|>` operator, I get what I want - if the item has `<pubDate>`, that's extracted and returned. But if it has `<updated>` instead, that will be extracted and sent. If both exist, the first will be returned.

```haskell
extractData :: [Tag String] -> FeedItem
extractData tags =
  let title = getInnerText $ takeBetween "<title>" "</title>" tags
      linkFromYtFeed = extractLinkHref tags -- youtube specific
      link = case getInnerText $ takeBetween "<link>" "</link>" tags of
        "" -> Nothing
        x -> Just x
      pubDate = case getInnerText $ takeBetween "<pubDate>" "</pubDate>" tags of
        "" -> Nothing
        x -> Just x
      updatedDate = case getInnerText $ takeBetween "<updated>" "</updated>" tags of
        "" -> Nothing
        x -> Just x
      updated = pubDate <|> updatedDate
   in FeedItem {title = title, link = link <|> linkFromYtFeed, updated = fromMaybe "" updated}
```

- The success in `extractData` did not last by the time it came to working with functions that had to interface with the DB. Had a lot of trouble writing that one function `processFeed :: URL -> App ()` which takes a URL (String), and an app config (`Config`) and then actually fetches the contents, then writes to the database. This was because I had a tough time unwrapping/wrapping to `IO ()` without losing the errors.. but then, I realized I had not really thought about error/crash strategy: like, when I extract feed items and attempt to write each link to the database, should I crash at the first error or should I just log it to the console and carry on with the next item?
- I decided that it was best to log and continue to the next. Then came the question of which function should do the logging? For now, the `insertFeedItem` (which takes a feed item and writes to the DB) is the one that logs... but that came about after so much wrangling with these functions. At the end of the day, I went with really simplified `insertFeedItem` whose return type went from `ExceptT ... ()` to `IO ()`... which I am not really happy about because a thrown error is not caught.
- Eventually, `insertFeedItem` got wrapped inside `processFeed` (which processes a single feed URL), which then got wrapped inside `processFeeds` which processes a list of URLs, simply mapping over the `processFeed` function.
- Overall — the good thing is that I managed to get a working function that took a URL and fed the feed items into the table. But the code is already somewhat confusing and there were times where things compiled and worked but I just couldn't get a complete understanding of what was going on in the wrapping/unwrapping — a feeling I commonly encounter when dealing with these functional programming languages.
- I spent time on finalizing the table schemas. The `link` is the primary key so duplicate inserts are prevented at the DB level besides being prevented at the code level.
- I am also briefly mulling if I could put all the code in a single file. I have modules around functions (like DB-related, RSS parsing related etc) but they are already coupled by sharing of types and whatnot. So I am thinking maybe for now I will put them all in a single Main.hs file and then extract out modules based on what natural grouping requirements emerge in that file.

###### Day 7

- Continuing from [day 6](./haskell-journal-day-6)'s thought, I put all the code (except the one-time Youtube feed link extractor) in a single file. While it felt like I had written a lot of code, it's just about 250 lines including some 25 lines of `import` statements. At some point in the project, I'll have to break this up but this is too early and unnecessary right now.
- The biggest win for today has been -> I got a good working prototype of a function that reads a table to get a list of rss links, then goes out to fetch each link and process it, and adds the posts from the feed to another table. And all of it done with the right kind of error handling (as far as my rudimentary tests are concerned). So now I could just invoke one function to fetch the latest updates from every rss link I have.
- I had a terrible time gaining some understanding of the underlying monadic things about my data structure `App`. I played around a bunch of options — like reducing the lower-level functions to just be `IO a` instead of `ExceptT ...` etc but things kept feeling messy. I did finally manage to keep them all neat and tidy into the `ExceptT` (because that's how one can safely hold errors). Briefly, my app kept crashing if a malformed URL was sent down the wire and I realized it was just a matter of me not handling a throwable `IO ()` in a function that fetched contents of a URL.
- Functions that use the connection pool (a.k.a functions that interact with the DB) were the hardest to write because the `withResource` function kept tripping me up. That function has type `Pool Connection -> (Connection -> IO a) -> IO a` , i.e. it takes a connection pool and a function that takes a connection and returns an `IO a`... but it took my stupid brain a long time to figure out how to bubble errors up from the inner function. Was a simple `try $` slapped in front .. but I had to make sure the `try`'s `SomeException` was returned as `AppError` afterwards. This piece was the one that actually caused all sorts of trouble in my intuition of the app's helper functions (involving database access), but once this clicked in place, a lot of things got simplified.
- Type-level reasoning saved the day a few times: I would write the `withResource` line, type annotate it, then figure out the inner function slowly by unwrapping and then wrapping the results...
- I'd start with something like this:

```haskell
...
res <- try $ withResource connPool handleSomething :: IO (...)
...
where
  handleSomething :: IO ... -- this is where I play with and finalze the type till compiler stops complaining
  handleSomething = undefined
```

- And then workout the `handleSomething` function by unwrapping/wrapping stuff.
- With one of the core prerequisites done, I am now going to do some work on finding out what I want the outputs to look like and how the CLI should behave. I am partly leaning towards being able to run a single command that produces a simple HTML file which I can just serve or see directly to get my "daily digest". But how would I mark the reads as reads if it's a static html file?
- Update: at the end of the day, I spent a little more time on the codebase. I was particularly looking for ways to extract some patterns out and minimize code. Somewhere, I feel like there are a bunch of utilities from the standard library that I could be using to wrap, unwrap, map over the monadic datatypes involved in the app at this point, but I couldn't really get a sense of what those would be. (The `hlint` does sometimes suggest interesting alternative options that make the code concise, without losing the readability mostly). I did realize though that I have a bunch of `try`s in the app and then I always have to handle the `SomeException` and convert it into my `AppError`... so I wrote a custom `try'` that I could use all over the place and never worry about having to convert `SomeException` to `AppError` again.

```haskell
try' :: (String -> AppError) -> IO a -> IO (Either AppError a)
try' mkError action = do
  res <- (try :: IO a -> IO (Either SomeException a)) action
  pure $ case res of
    Left e -> Left . mkError $ show e
    Right a -> Right a
```

###### Day 8

- While I actually didn't want to work on the project today, one thing led to another and I ended up working on it.
- I was watching [this video](https://www.youtube.com/watch?v=kbFGvUXqUcw&pp=ygUSaGFza2VsbCBleGNlcHRpb25z) on exceptions and realized I could use a simple `IO a` type for my functions instead of `ExceptT...` because all `IO a` types _can_ potentially throw. Combined with a custom `Exception` instance for my `AppError`, I could potentially get rid of a few `runExceptT`s in the code — so I went about doing it and the whole app got converted into a simple `IO a` (i.e., the `App a` wrapper stopped being an `ExceptT ...` and became an `IO a`). There were some places where I had to handle things correctly so that errors were managed properly (like when trying to insert a link, the inner function crashes if the SQL insert query fails — but the handler that uses the inner function shouldn't crash, because failing for one feed item shouldn't fail others).
- What I like about this approach is that I can have any throwable `IO a`, and I can simply run it through `failWith <AppError>` and it will produce an `IO a` or throw with the right kind of `AppError`. i.e, it takes an `IO a` that could throw a `SomeException` and converts it into an `IO a` that could throw an `AppError`.
- The codebase became much cleaner and reasoning about the steps is now far simpler. I also discovered there was one place where I was returning an `IO a` for no reason — the function could be very pure and return `a` simply.
- After this, I couldn't stop. I ended up writing a simple command system for the app so I can now compile the binary and run a few commands like:

```bash
> rss-digest add <url> # this adds an XML URL to the database, correctly showing an error if the URL is already added or it's an invalid URL.
> rss-digest refresh # this fetches all feed links from all the RSS feeds in the database, and then updates the feed_items table.
> rss-digest purge # nukes the whole thing
```

- I wanted to check the size of the binary and it was a whopping 64MB. Ignorant me was surprised as heck. I asked ChatGPT about it and it said it was because the binary was packing everything to be self-sufficient. One of the options it gave was to use dynamic linking instead of static linking — I had concerns about this because how would that work if one were to distribute the binary? The reduction was anyway not all that great. There were other options it suggested like "no profiling", turning off debug mode, using some "O2" mode of optimization etc... nothing really worked.
- One thing I missed in the ChatGPT list of recommendations was to use the `strip` command on the binary. Instead, I went to Stack Overflow and Google... and one of the suggestions there was `strip` too. So I did that and the binary came down to 41MB which is still humongous (for comparison, GitHub's CLI tool `gh` v2.49 is ~48MB). `strip` removes all the symbols from the binary. I did a test run of the binary after doing the `strip` and it was working OK. (update: if I compile the binary with dynamic linking, and then do a `strip`, the binary size is about 200kb)
- I'm quite happy about the way the project has shaped up so far. Might do a recap of what I learned, patterns that seem to emerge etc at some point.

Update:

- I did some more work as I was bored and couldn't stop being obsessed with the project for a bit.
- I wrote a Makefile because I was frequently running `cabal build ...` and `cabal install`. This made the process quicker.
- I found a problem where, when I added more constructors to my `Command` data type, the compiler didn't warn about missing pattern matches in the `main` function where I was handling the command. It turns out I had to enable some flags (specifically `-Wincomplete-patterns`). I ended up using `-Wall` and fixing a bunch of lint warnings like unused declarations and imports and adding type annotations where I hadn't written them out explicitly. This had zero impact on the built binary size, though.
- I added a couple of commands to remove a feed and list all existing feeds. The remove feed command made me realize that I need to set up a foreign key relationship between the feeds_table and feeds — so that when I remove a feed, I also remove all the posts that came from that feed URL. I've noted this for later implementation.

###### Day 9

- Finally managed to add some variant of a "daily digest" system today.
- Took a while to think of a bare minimum implementation of the digest logic. The table captures _when_ a feed item/post was added (basically, when you run a `refresh`, it gets all the posts from all the RSS feeds you've added and adds the posts—those that aren't already in the DB—along with the current date, which is different from the published/updated date). This gives me a way to prepare a daily digest for any given day: I just have to pick the items for that day.
- The pros in this logic are that I can prepare a digest for any day, and it's kind of simple (maybe too simple). It's also idempotent unless you do a refresh on the same day and there are new feeds added. The cons, of course, are many: there's no way to mark an item as read, so what you have is a growing list of posts as you read them—but I'm okay with this implementation for now. As I work through and use the system, I'll find more ideas to refine or pivot.
- I think I was at that familiar stage of any side-project where I was doing a lot of side-quests instead of writing the main piece: the "daily digest" logic. Added other niceties: confirmation steps for removals, a purge/nuke option, and more critically, modified the schema so that feed items/posts are foreign-key linked to the feed in the feeds table. So, if I delete a feed, all the posts associated with it are also removed by SQLite, thanks to the constraint.
- Haskell lint offered a lot of interesting suggestions to make the code more concise. I found that in a few places, I had to suppress or ignore the suggestions to keep the code readable for future-me.
- There was also a point where I was trying to reinvent `>>=` by doing `join . fmap`, but chatGPT reminded me that I could simply use `>>=` instead. That made the code concise. I was thinking if I'd end up not understanding this code in the future but decided to keep it. It also got me thinking about [this discussion](https://mail.haskell.org/pipermail/haskell-cafe/2009-March/058475.html) that I stumbled upon recently (one person argues Haskell style guides should recommend more simple/readable code, while another argues it's up to the developers to learn to read terse code).
- The digest I produce is an HTML file with some styling. I generate this HTML file by using a template and then just swapping/replacing some parts of the template with relevant data. I learned how to bundle the template as part of the binary by inlining/embedding it using the `file-embed` package—all of this thanks to chatGPT.

###### Day 10

- The digest list I generated seemed bland and unfriendly as a single list, so I grouped them based on the feed URL (eventually, feed title). This improved the experience of viewing a day's digest, as it now appears as a [grouped list](https://imgur.com/sk14hRb). This change also required updates to the template.html file.

- For grouping, I initially considered using the Map datatype but felt it was overkill. Instead, I decided to write small functions to handle a datatype which is Map-like `[(key, value)]`.

- I occasionally encounter "bus errors," which are usually related to out-of-memory issues. I suspect this is due to Haskell's laziness. These errors typically occur when fetching feeds, but randomly. I need to investigate the cause.

- I'm now considering having this tool spin up a local server to serve the digest on-demand. Commands could also be invoked from the web UI. Alternatively, I could explore concurrency to allow parts of the feed item refresh process to occur simultaneously.

###### Day 11

- Made significant improvements to the tool. Now able to refresh a single feed and build a digest for a date range. The digest selects items with `published` dates (`updated` in the database) within the specified range. Added a command to create a digest for today.

- Updated code to handle edge cases, such as attempting to process a feed not yet added to the database. This prevents issues related to missing feed IDs in the database affecting the feed_items table.

- Implemented numerous improvements to [the template](https://i.imgur.com/4GJi0bd.png). Error messages are now more user-friendly and informative.

- Discovered multiple feed items with `null` updated values due to the datetime parser returning `Nothing`. Added four new date formats to address this issue:

```haskell
parseDate datetime = fmap utctDay $ firstJust $ map tryParse [fmt1, fmt2, fmt3, fmt4, fmt5, fmt6]
   where
     fmt1 = "%Y-%m-%dT%H:%M:%S%z"
     fmt2 = "%a, %d %b %Y %H:%M:%S %z"
     fmt3 = "%a, %d %b %Y %H:%M:%S %Z"
     fmt4 = "%Y-%m-%dT%H:%M:%S%Z"
     fmt5 = "%Y-%m-%dT%H:%M:%S%Q%z"
     fmt6 = "%Y-%m-%dT%H:%M:%S%Q%Z"
     ...rest of the code
```

- Renamed the project from `rss-digest` to `rdigest`.

- Progress on Haskell-specific learning has slowed. Excitement is waning due to lack of challenges outside the comfort zone. Considering adding server capabilities to the tool, allowing it to serve the digest. This would involve UI updates to accept date ranges and implementing server functionality.

###### Day 12

- All improvements made on [day 11](./haskell-journal-day-11) went to waste because the app kept crashing when I tried to 'refresh' the feeds. It either crashed with a `bus error` message, a `malloc` related error, or in the worst case scenario, just got stuck while the machine ran out of memory and my MacBook asked me to force quit some apps.

- I went on a wild goose chase trying to isolate the issue and then test various combinations. I isolated the issue to the fetching of feeds from the feed URLs, but all sorts of changes to that function did not help. Going lazy ByteString didn't help. Using an alternative library (wreq, req etc.) didn't help either.

- I asked a bunch of folks via the usual help channels: FP slack #haskell channel, FP India Telegram channel, and reddit.

- I spent a day obsessing about this, trying everything. I then decided to give it a break because it was getting on my nerves.

- Finally, the breakthrough came when I asked on IRC (Libra server, #haskell). One of them pointed to a known issue with `ghc < v9.2.6` in the `GMP` module (which I, being ignorant, obviously had no clue about). Updating my `cabal` and `ghc` just magically fixed the issue. My app finally is able to terminate correctly and function absolutely well! (I don't mind the 1G memory footprint it has when it refreshes all feeds).

- One learning did come out of this though: I was concatenating strings and forming SQLite query strings that way — but I was advised to use parameterization, so that change was incorporated.

- After almost two days of drudgery and not having any idea about how to fix the crashes, there's now excitement that the app works and I can continue adding features to it.

###### Day 13

- Added an important update: rdigest requires you to specify where to store the db and digest files via environment variable. This was surprisingly easy to implement.

- Attempted to add subreddit RSS, which proved very temperamental. It works sometimes, but often no feed comes through because Reddit aggressively blocks direct access by tools/scrapers. Went on a troubleshooting journey trying to solve this by using alternative libraries like wreq, but these didn't help. All these "simpler" libraries were actually much harder to get started with and use. While this arguably makes them more typesafe, they are poor for rapid prototyping. The examples in their documentation are also inadequate. Returned to the original library (Network.HTTP.Simple) and added a user-agent header, which occasionally fixes the Reddit RSS issue.

- There are spots in the code where better use of available instances for particular datatypes could improve readability. For example, in the `runApp` where the environment variable is retrieved:

```haskell
runApp :: App a -> IO ()
runApp app = do
  let template = $(embedFile "./template.html")
  rdigestPath <- lookupEnv "RDIGEST_FOLDER"
  case rdigestPath of
    Nothing -> showAppError $ GeneralError "It looks like you have not set the RDIGEST_FOLDER env. `export RDIGEST_FOLDER=<full-path-where-rdigest-should-save-data>"
    Just rdPath -> do
      pool <- newPool (defaultPoolConfig (open (getDBFile rdPath)) close 60.0 10)
      let config = Config {connPool = pool, template = BS.unpack template, rdigestPath = rdPath}
      res <- (try :: IO a -> IO (Either AppError a)) $ app config
      destroyAllResources pool
      either showAppError (const $ return ()) res
```

- In this code, `app` returns an `IO a` which is handled as a potentially-throwing action. However, the extraction of `rdPath` happens outside the `try`. Better code would follow the happy-path pattern, with errors handled inherently in a global `try` block. The `runApp` function is intended to be that global try block for all `App a` actions, but the environment variable extraction happens outside this boundary.

- At some point in this Haskell journey, the project began feeling like routine code similar to Typescript. This prompted reflection on the benefits derived from using Haskell beyond learning the language and code architecture. Notable advantages include:

  - Easier writing and reading of async/effectful actions due to `bind` abstractions (sugared as `do` blocks) with upper-level error handling
  - Clean implementation of applicative parsing, which would be challenging in non-functional programming languages
  - Convenient data types and constructors that simplify logic construction

- Hlint often recommended ways to make code more concise through [point-free](https://wiki.haskell.org/Pointfree) style or using operators. For example, this code:

```haskell
parseURL :: String -> Maybe URL
parseURL url = case parseURI url of
  Just uri -> (if uriScheme uri `elem` ["http:", "https:"] then Just url else Nothing)
  Nothing -> Nothing
```

Can be written as:

```haskell
parseURL :: String -> Maybe URL
parseURL url = parseURI url >>= \uri -> if uriScheme uri `elem` ["http:", "https:"] then Just url else Nothing
```

- Sometimes explicit destructuring and imperative-style expressions were preferred for better understanding of the logic.

- This was largely a matter of familiarity. With more exposure to situations requiring unwrapping double monadic structures, the use and understanding of `>>=` became more natural:

```haskell
getDomain :: Maybe String -> String
getDomain url =
  let maybeURI = url >>= parseURI >>= uriAuthority
   in maybe "" uriRegName maybeURI
```

- This experience recalled the [exchange](https://mail.haskell.org/pipermail/haskell-cafe/2009-March/058475.html) on terseness and readability.

- I think sometimes I am able to think very cleanly thanks to the type-system and the functional-style of programming but there's certainly the feeling that I am not completely tapping into that potential. Being able to express the logic in the code as a beautiful equation is still elusive.

###### Day 14

- I added 286 YouTube channel RSS feeds (from channels I'm subscribed to) to my personal `rdigest` collection. This surfaced some usability challenges. For any given day, more than 70% of the links were from YouTube, highlighting the need for better categorization.
- Initially, feeds were grouped by the source URL, but this wasn't sufficient for YouTube because all feed URLs have the same hostname (`youtube.com`). I needed a way to distinguish them by the feed title. However, I wasn't capturing the title, and `title` wasn't even a column in the `feeds` table. So, I updated the database schema to add a `title` column—essentially setting up a basic migration system. I experimented with a simple "up-only" migration approach, which worked reasonably well and now allows me to run multiple SQL queries from a file in sequence within a transaction.
- Adding titles to feeds enabled grouping by URL while displaying titles, making the digest easier to scan. This required reconsidering how I structured the data. I went from grouping as `(URL, [FeedItem])` (where `FeedItem` represents an individual post from the feed at `URL`) to `((URL, String), [FeedItem])`. Though straightforward at the type level, the change needed adjustments in functions. The digest grouping now happens within the function that writes the digest file since that's where grouping is required. It's a relief to be able to use tuples as keys without having to worry — imagine facing this in the Javascript world.
- Once again, I enjoyed the process of writing code as if functions already existed, defining type annotations and `undefined` placeholders, and then iteratively filling in the `undefined` parts with help from the language server and occasionally ChatGPT.
- Another crazy thing happened with the binary size. The un-stripped one (but with all optimizations from cabal and GHC) is over 80MB. Stripping it of symbols reduces it to 51MB. I was randomly searching for discussions about Haskell binary sizes and discovered a tool called `upx`. Using that, the binary size dropped to 15MB. Can you imagine?!

###### Day 15

- One of the next things I decided to do was to set up the entire `rdigest` workflow somewhere it could run on a schedule and produce digest files as output. I didn't think much about this initially; I simply discussed with ChatGPT the shortest and easiest way to host the digest files (just plain HTML with some in-built styling). My thought process was to work backward: first, get the digest HTML files hosted and served from somewhere (I decided on GitHub Pages as the easiest solution), and then figure out how to update/produce daily digests using a cron job. I assumed GitHub Actions would suffice for the task.

- The hosting bit worked fine, except I didn't have an `index.html` file, so GitHub Pages threw a 404 error until I created and uploaded one to the repository. The Action/Workflow file was also generated within seconds, as ChatGPT seemed to have anticipated my next move. However, what didn't work was that the binary failed to run—a cryptic exit code `137` abruptly terminated the runner, and the entire action quit. I spent some time tinkering with troubleshooting options, but my efforts were half-hearted. By this time, other complications had surfaced. For example: "How would I update the feeds list if I wanted to add a new feed?"

- I decided to pause my efforts on this and form better ideas around how to transfer the entire experience to "the cloud" so that `rdigest` would be available to me wherever I go, even if I don't have access to my personal machine.

- In some aimless meandering through threads on the Haskell channel on the Functional Programming Slack, I stumbled upon a link to [Gabriella Gonzalez's talk on Monad Transformers](https://www.youtube.com/watch?v=w9ExsWcoXPs&ab_channel=OST%E2%80%93OstschweizerFachhochschule). `rdigest` had gone through a phase where I experimented with monad transformers (`ReaderT` and `ExceptT`), but I had to abandon that work due to my poor understanding of transformers at the time. The talk rekindled my interest in them, and I've been considering revisiting the idea of transforming the app to use `ReaderT` at the very least. Gonzalez mentioned avoiding `ExceptT` in favor of lazy `IO`, and I find myself inclined to agree with that perspective.

- I also happened to read some reiterations on the beauty of domain modeling through types and the functional-core/imperative-shell concept. I couldn't help but recognize that my code is an unabridged mishmash of functional and imperative directives. A lot of it feels imperative to me, and I think I might benefit—sooner rather than later—from taking a closer look at the structure of the code. Refining (or even refactoring) the app to clearly delineate between `IO a` functions and pure ones seems worthwhile. The app currently has a heavy effectful stance because it involves substantial reading and writing to the database and the file system, along with `fetch`-like calls. At the same time, it also includes a host of purely functional operations. Clearly separating these would likely improve the maintainability and clarity of the codebase.

###### Day 16

One of the things that has been bugging me since I wrapped most bits on the `rdigest` project was that I could not get it to work in a Github repo where I planned to run it on a cron so that digests get created automatically every day and hosted somewhere so I can read from anywhere.

My first attempts to do this was to upload my locally-built binary and see if that works in a GH action running on a `macos-latest` machine — it did not. I spent a tiny bit of time before my day-job took precedence and because I couldn't get it to work, I decided to park there and come back later.

Coming back later, I decided to make the `rdigest` repo build its binaries on `ubuntu-latest` and release the artefact in [the repo](https://github.com/chandru89new/rdigest/releases). This was exceedingly simple (probably needed a couple of iterations to get the right configuration options for GHCup, Cabal, GHC, tagging etc.). This worked nice, and all that was left to do was to consume the release in my [`rdigest-data` repo's](https://github.com/chandru89new/rdigest-data) cron action.

With a few iterations, I got all of it tied up. The cron ran once every day and updated the digest for a particular day. With GH Pages setup on that repo, I was able to just hit the URL and see a list of all digests and read each digest at leisure.

But this unearthed a new problem: since I ran the digest update just once, and the process would only update for "today" (whatever today was at the time of running the binary), some posts could "slip" the digest depending on the timing. I haven't spent much time thinking about the optimal approach to fixing this but in the meantime, it made sense to just update all digest-days once I have refreshed (and saved posts from) all feeds in my list. Ugly, nuclear solution but it ensures all my digest files are up-to-date.

Life is getting a lot in the way in recent times so there's been a pause in activity but I am itching to refine the `rdigest` codebase to elegantly separate out the functional and imperative bits. And also revisit what interesting things the project can spawn into and make it more useful than just producing digests.
