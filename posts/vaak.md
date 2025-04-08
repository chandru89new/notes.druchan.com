---
title: "Vāk"
date: 2025-03-01
slug: vaak
status: draft
---

Sometime in May 2023, if this blog's [commit history][ch] is to serve as a record, I ported over my Tumblr blog to an in-house, custom-built blog generator. I recall this period being quite exciting: I was new to Purescript, I automated pulling all content from my Tumblr blog and converting them to Markdown, and I built the in-house blog builder from scratch as well, glueing together small, iterative features like archive grouping, feed generation, simple caching to prevent unnecessary rebuilds and so on.

Till about a month back, the code that generates the blog, and the actual blogposts (and some JS and all images) existed in a single repository. There was no need to separate them and organically, the two parts of the blog (the generating code, and the contents) grew together. It was also very convenient to be able to test the blog-generating code while _building_ the blog from the contents.

Close on the heels of [working on chequera][chequera-post], I had this urge to separate the blog repo into its constituent parts. I decided to keep the actual blogposts in the original repo (because the repo is conveniently named [`notes.druchan.com`][notes-repo]) and start a new repo for the blog-generating bits.

And that's how [`vaak`][vaak] got created.

I've been chipping away at `vaak` for a few weeks now and the cross-polination between `vaak` and [`chequera`][chequera] gives me immense joy. `vaak` has benefitted quite a bit from `chequera` in terms of logging, and in the GH workflows to bundle the app.

`vaak` serves a very personal, one-person purpose. It is not a general-purpose static site builder, obviously, and it is not (yet) a general-purpose static blog builder either. But I can see that it is gravitating towards configurability: today, I added a feature that allows me to set folder paths to indicate where the blog's contents/posts are, where the site should be built and where to pick the design/template from and such. Previously, this was hard-coded and that meant I couldn't use `vaak` for another blog (if/when I start another).
