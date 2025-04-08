---
title: "Is it time for another side-project yet?"
date: 2025-02-16
slug: chequera
ignore: false
---

So, back in November of 2023, [I wrote briefly](./js-promise-to-purescript-aff-ffi) about working on a tool that would extract SQL query blocks (from markdown files) and run them in [Steampipe](https://steampipe.io) to test if they work or not. Typical of side-projects, it got abandoned after a while.

Over the last weekend, I decided to revisit it. I considered picking off from where I left, but decided to start from scratch and this time, not in PureScript but in Haskell (fresh from the exploits in [rdigest](https://github.com/chandru89new/rdigest)) so I could build and distribute binaries that can be used directly instead of depending on Node.

The reason for building this tool is that there are tons of example Steampipe/SQL queries on our [Steampipe Hub](https://hub.steampipe.io/) and they serve as a springboard for folks trying out our plugins. If the queries fail, that's a bad experience. We want the example queries to work.

But with hundreds of such example queries, and near-frequent updates to some of the plugins, it gets really hard to check the code.

That's the motivation for "[chequera](https://github.com/chandru89new/chequera)".

Testing the hub code can be broken down into three parts:

- extract the queries from a list of files (the hub code for each plugin is generated from plugin docs, all written in markdown files and hosted in a GitHub repo)
- run the queries through Steampipe and collect the errors
- report the errors / log them

Typically, you'd go for a markdown parser library but I thought that would be an overkill. Also, there's some non-standard syntax involved that might complicate things if I picked a standard parser.

As an example, Steampipe plugins can run in default Postgres [FDW](https://www.postgresql.org/docs/current/postgres-fdw.html), or you could run them in a SQLite instance. Subtle differences exist in the example code/queries between the two. So the markdown files have two blocks: one annotated as `sql+postgres` or `sql` and the other as `sql+sqlite`. This helps the Hub render a codeblock with a dropdown to choose between the two SQL flavors [like here](https://hub.steampipe.io/plugins/turbot/aws/tables/aws_accessanalyzer_analyzer#basic-info).

Asking Claude to get me started here was a big mistake. It took me on a goose-chase, suggesting that I should use a combination of `dropWhile` and `takeWhile` (and then refining it's strategy to use `span`). The solution didn't work (or rather, I couldn't get it to work) and I ended up rolling a plain ol' [TCO recursion](https://github.com/chandru89new/chequera/blame/42e82f3d48ddd9fb2127f383edf476d13959c180/app/QueryExtractor.hs#L15). This would undergo several iterative improvements again but the core of it remained the same. Took me a long time though: this is why parser combinators exist and it's best to approach this from that angle instead (but I ain't got time for that now).

The rest of the program was close to a smooth-sail with the occasional jitters (like passing a string down a wire without getting into quote/unquote troubles).

One area that I need to improve on is handling IO errors. I had [similar issues](./haskell-journal-day-5) in my other project.

In a revamp of [vāk](https://github.com/chandru89new/vaak), the custom Node script that generates my blog, I converted a whole lot of `ExcepT` functions into simple `IO`s, simplifying the app considerably. All of those `IO`s got rolled up at the outer-edge of the app into an `ExceptT`. This made the app lose a lot of lifting into the `Except/IO Either` monad, and simplified the functions.

I decided to adopt the same here. And it was fairly OK. But there were a couple of foot-guns that I inadvertently triggered and had to write some patches. I think the most critical learning here is that unlike Elm which guarantees runtime-safety, Haskell (and PureScript) do not. Yes the comparison is probably not fair but it's a note-to-self so it's okay. In order to get to runtime-safety in Haskell/PureScript, I'd probably have to lean more into the `ExceptT` monad transformer for any `IO` so that every `IO` is safely wrapped and handled higher up the stack. (update: after a couple of hours of late-night tinkering, `chequera v3.0` does this.)

Like most projects, this one had a lot of momentum initially. Where I'd like for `chequera` to go from here is to run it on the plugin docs and raise tickets in the respective plugin repos. Then, hopefully, I will try and pitch it for adoption into our plugin-related workflows so that every plugin change and new plugin additions go through a step where `chequera` verifies that the example code works.

Then there's also the SQLite code blocks that would need to be tested. At this time, the setup for SQLite happens inside a SQLite interactive (where you have to load the plugin extension and all that), so I am not sure how I'd be able to test those queries yet.
