---
title: "One year of vāk"
date: 2026-02-07
slug: one-year-of-vaak
status: published
collections: Project journal
---

Some time back, in a routine cleanup of my many drafts, I found one where I "introduced" [vāk](https://github.com/chandru89new/vaak), the blogging script/tool I use to run my blog. I never quite finished that draft. I am certain I must've dissuaded myself from writing it by thinking, "no one's going to read it anyway."

About a couple of days back, I introduced a new feature to vāk: collections. Collections is just "tags" in some other shape. Testing this new feature is how I stumbled on the old, unfinished draft introducing my custom blogging tool.

This then led to checking the earliest commit in vāk's repo:

```sh
commit a19750ed19c1e4fd684092b7a7be6b263a3d7038
Author: Chandru <...>
Date:   Fri Feb 7 18:49:37 2025 +0530

    init commit
```

That is about a year ago. Calls for some kind of a small celebration.

But in truth, vāk predates this timeline. The contents of my blog and the tool existed in the same repo. Feb 7, 2025 is the date I separated the tool (vāk) from the blog (this one) and initialised a new repo for the tool. Checking the earliest commit on the blog itself, back when vāk was still a part of it:

```sh
commit 244434366b7f5b11c0850041b52c50345e447ce9
Author: Chandru <...>
Date:   Fri May 12 16:23:53 2023 +0530

    Init commit.
```

That's almost 3 years ago.

<div class="separator"></div>

In keeping with the mores of my time in the 2000s, I set up my first blog on Blogger.com. I might've set up a few in haste and deleted all of them (in haste too). When I had much to write about, like the journals during my first stint in Ahmedabad, I set up a blog on Tumblr. Then, back in Chennai, I set up a new one, on WordPress this time. This was also the time when I attended a blogger's meet conducted by [IndiBlogger](https://www.indiblogger.in/). At approximately 4-5 posts a month on average, I published about 50 posts on the WordPress blog before retiring it (I have no idea why) and resuming my writing on Tumblr.

Tumblr was a go-to whenever I needed a blog or a website to put something up. I had gotten used to its theming (which was just CSS wrangling). It was just way too easy to set up and run.

Until finally, I decided that as a programmer, it would be nice to have a blogging tool built by hand. Might've been the [rite of passage](/prog-rites-of-passage) thing.

<div class="separator"></div>

Around this time, I was trying to learn Haskell and PureScript. My blog posts were going to be simple Markdown files and I knew it was trivial to convert Markdown content into HTML content using JS libraries. PureScript offers a really simple and easy [FFI](https://book.purescript.org/chapter10.html) so I started building out vāk in PureScript.

Those initial commits (3 years ago) started as a `.purs` script that fetched all my posts from Tumblr (via an API) and rewrote them as Markdown files, because at the time, Tumblr's API returned an HTML version of the posts.

Then, I wrote a bunch of functions that generally converted a given Markdown file into an HTML file. The reason for this roundabout was because future posts were going to be written in Markdown.

A few iterations later, broad contours of the system were ready. I had one repo to rule them all: the blog, the content, the published website etc.

About a year ago, I split the tool into it's own repo and called it vāk. ([Why vāk?](https://github.com/chandru89new/vaak?tab=readme-ov-file#colophon)).

<div class="separator"></div>

In the years since, there have been only two major upgrades to vāk besides the usual and infrequent tweaks and clean-ups.

The first is an internal detail. I used something called [monad transformers](https://en.wikipedia.org/wiki/Monad_transformer) to create better abstractions to run functions and catch errors.

The second is making the templates very customisable by relying on the [Nunjucks](https://mozilla.github.io/nunjucks/) templating engine. This came about as a continuation of my unnecessary effort to make vāk a tool anyone can use.

In a strongly-typed functional language, changes are a delight to make. I often employ this idea called type-driven design; it's like sketching out the app (or feature) on a wireframe of types before implementing the functions that do the thing.

I picked up a few PureScript/Haskell skills along the way. Prior to working on vāk, I kept away from monad transformers and hadn't really worked with concurrency. I hadn't architected anything larger than a script that solved LeetCode problems. Building vāk on PureScript gave me a chance to do all of that and more.

<div class="separator"></div>

In the last few weeks, when I updated the program to use Nunjucks, I used Claude Code as an assistant to implement many of the changes. PureScript is notoriously niche so LLMs do not always get things right as often as they do when writing Python or TypeScript. But they do get you close enough.

I continue to like the satisfaction of writing things myself than relying on an agent (except for work where dictates of productivity and releasing a feature trump personal artisanal satisfaction), so I tend to _ideate_ with Claude Code and then implement things by hand. Features, bugs, optimisations: I follow the same simple rule.

<div class="separator"></div>

A few of the hobbyist programs I build get used often, fewer still give me an opportunity to tinker with for a long time. vāk happens to be one that allows for both. It's one of those [home-cooked software](https://www.robinsloan.com/notes/home-cooked-app/) things that I keep trying to _generalise_ for no reason.
