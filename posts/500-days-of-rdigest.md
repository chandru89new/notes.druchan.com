---
title: "500 days of rdigest"
date: 2026-03-07
slug: 500-days-of-rdigest
status: published
collections: Functional Programming, Project journal
---

[`rdigest`](https://github.com/chandru89new/rdigest) is a small CLI-based tool I made in late 2024. It began as a way to manage my daily reading (online digital consumption) because YouTube's UI was distracting, RSS feed readers and their infinitely-scrolling pages were overwhelming and I had cut out social media from life eons ago. TL;DR, digital content consumption was at some unmanageable crossroads in life and I had to find a way to deal with it.

I've been using `rdigest` for 500+ days now. Of the handful of side-projects I built to scratch my own itch, this remains a powerful daily-driver.

--

###### Contents

- [A quick brief of what `rdigest` is](#i.)
- [Learning by building](#ii.)
- [Hand-crafting software and LLMs](#iii.)
- [Scratching an itch vs. building for others](#iv.)
- [Sporadicity](#v.)

--

###### I.

Now, this part about what `rdigest` is (and why) is for the accidental reader who landed here god knows how:

`rdigest` is technically a feed reader but it's also not really a feed reader. It collects links from all the feeds you follow and then creates a daily digest for you. The daily digest is just a finite bunch of links. A bunch of links grouped by source and zero algorithm. A bunch of links you look at, skim through, click on the ones you want to actually read or view... and then you're done with your digital content catch up!

That last bit is the critical piece, the linchpin ideology.

The way we consume digital content today is horrible. There's an infinite, never-ending stream hitting at us at all times. All kinds of platforms have interfaces that are designed cunningly to trick your brain into staying on the platform for as long as possible. You're thinking about Twitter, Instagram, TikTok and YouTube, but even other outlets like blogging engines, content management systems, AT-Proto interfaces (Mastodon/Bluesky) and even popular feed readers promote and enable these "infinite stream" interfaces.

This leads to all kinds of problems. Attention is low, ability to sustain a longform is gone, and no interface or product gives you this feeling of closure. The same mechanics of constant connectivity over work Slack ruining work-life boundaries are at play: it never feels like you're done reading, seeing, hearing the things you want to for a given day.

Alright, so that's the tirade against dark-pattern-embracing products streaming endless content and hacking into our neurons.

There may be many antidotes to this. `rdigest`'s idea is borrowed from the old, physical newspaper model that I [harp about](https://notes.druchan.com/escape-from-algotraz#v.-%22done%22-for-the-day). Imagine the morning newspaper (ie, if you're old enough). The paper arrives. You skim through the headlines, read the ones that interest you, and then you're done for the day. There's nothing more to do there (unless you were some hotshot that got the _evening_ paper too). `rdigest` pretty much does the same, except it is about links from RSS feeds you follow and it's got no frills. Just a page of links like this:

<p>
<a href="/images/rdigest.png" target="_blank">
<img src="/images/rdigest.png" />
</a>
</p>

--

###### II.

Reminiscing about a "hand-written" side-project in the age of LLM-written software seems weird and futile. There's nothing special anymore about building software except for the big picture bits and the devil-is-in-the-details bits.

And yet, artisanal software, especially of the crude, [home-cooked](https://www.robinsloan.com/notes/home-cooked-app/) kind might retain its charm.

I had two hopes when I began `rdigest`. One, to build something that eventually helps me manage my daily digital consumption (that had spiralled out of control to the point of giving up on online reading). Two, to learn a programming language (Haskell in this case) along the way.

I [kept a journal](https://notes.druchan.com/haskell-journal-1) while I built `rdigest`. The first entry goes:

> Decided to finally build something in Haskell to learn the language. So far, I've been solving puzzles and similar tasks, but nothing has given me the confidence to say, "Yes, I can build that in Haskell."

As I built out `rdigest`, I ended up learning nuanced things about file I/O, batched concurrency, safely interacting with SQLite, implementing a small migration module, and more, all from within the Haskell ecosystem. Like all side-projects, it was fun, [it was frustrating at times](https://notes.druchan.com/haskell-journal-1#day-12), and thankfully it also ended up being rewarding.

--

###### III.

Work on `rdigest` began in late 2024. By this time, I was using ChatGPT at work as an intelligent rubber-duck that talks back. Whatever I'd have googled or Stack Overflowed, I ChatGPT'd.

`rdigest` was built by hand but definitely helped by inputs from ChatGPT. Of course there were also many instances when the LLM sent me on wild goose-chases and proffered irrelevant complexities.

> Wrote some initial code based on ChatGPT's example of scraping. However, ChatGPT got the `attr` function wrong.

> ChatGPT suggested `optparse-applicative`, but I decided it was overkill for what I needed. A simple `--url <url>` argument was enough.

> I had a long chat with ChatGPT about these things, asking it about the idea of bubbling up the errors from ExceptT without having to do `runExceptT` wherever I wanted the error to be bubbled up but the ideas it returned were not working or not useful — or in some cases, it was just reinventing the ExceptT or ReaderT monad transformers.

But also:

> ... I learned how to bundle the template as part of the binary by inlining/embedding it using the `file-embed` package—all of this thanks to ChatGPT.

> Asked ChatGPT for a good web scraping library in Haskell. It suggested `tagsoup` and `html-conduit` (for fetching the source). Took a look at the examples and docs... seemed a little hard to grasp. Asked ChatGPT for a simpler alternative, and it suggested `scalpel`. Liked it, and decided to use it.

Claude had not yet come up as a significant competitor. Today, I don't use ChatGPT almost ever.

--

###### IV.

For a very long time — ie, over a year — `rdigest` remained a CLI-only tool. The only way to add feeds, manage them, produce a daily digest, and so on was to use the tool in a terminal.

But right there on my [day 1 journal entry](https://notes.druchan.com/haskell-journal-1#day-1), I had wanted to also make `rdigest` spin up a local server so that the feeds could be managed and daily digests could be viewed on a browser.

Life got in the way. I would occasionally push an update or two. I even built a now-defunct feature that sent the daily digest links via Telegram. But the server feature never happened.

I finally managed to find some motivation to build out this feature in the last week. What's special about this is the stack: the heavy-lifting backend, server and CLI are all in [Haskell](https://www.haskell.org/), a pure functional language, and the frontend application that renders a near-brutalist, minimal web interface is written in [Elm](https://elm-lang.org/), a pure functional language inspired by Haskell. There was a brief moment where I considered [htmx](https://htmx.org/), but chose Elm eventually.

The local server feature is not something I use every day. I have [a different setup](https://github.com/chandru89new/rdigest-data/blob/main/.github/workflows/refresh.yml) to make [the daily digests available "on the cloud"](https://chandru89new.github.io/rdigest-data/) so I can view them no matter where I am, even if I don't have my laptop. In retrospect, maybe this was the friction that kept me from building the local-server feature; I didnt really need it.

But, like my other project [vāk](https://vaak.druchan.com/) where I keep wobbling between "make this usable for everyone" and "just build things for myself", the thrust for `rdigest`'s local-server feature comes from wanting to make this tool easier to use for others as well. You know, just in case. The odds of someone using it are lower than the odds of a comet striking our planet in the next fifty years. But just in case.

--

###### V.

Work on `rdigest` happens sporadically. The [commit history](https://github.com/chandru89new/rdigest/commits/main) says I worked on it for a few concerted days in Jan 2025, then March 2025, then a big sabbatical till November 2025 and then now in March 2026. Big periods of inactivity, small chunks of moderately intense activity. Basically, the tale of every other side-project that gets used routinely.

This pattern repeats itself in `vāk` too, and then also on my toy npx-powered game [`wordladder`](https://github.com/chandru89new/lvnshtn/).

It's worth talking about because going back to these projects after a long hiatus does not involve broken builds or security conflagration or fuzzy/messy recollection of the modules/functions... you know, the kind of things you'd expect in projects built in weak languages unfortunately powering the world.

Instead, there's clarity, assurance, and guarantee. I attribute most of this to the semantics of the languages. `vāk` and `wordladder` use PureScript (a Haskell-inspired language targeting Node/JS environments). `rdigest` uses Haskell and Elm. Changes and even massive refactors are not scary.

--

So yeah. 500 days of `rdigest`.

I know. All you've been thinking of is, "the project needs a better name."
