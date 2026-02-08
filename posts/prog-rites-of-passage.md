---
title: Programming rites of passage
date: 2026-02-02
slug: prog-rites-of-passage
status: published
collections: Programming
---

Much to my sadistic little delight, I read this morning that vibe-coding (and other similar variations of LLM-driven software building) [does not help you acquire skills or learn much](https://arxiv.org/pdf/2601.20245).

> LLMs, on the other hand, are trying to give you the sharpest, closest solution possible. When learning through an LLM (especially around bug triangulation, troubleshooting etc), there is hardly any room or potential for ancillary learning.
>
> Although I have no data on this, I tend to believe that ancillary learning plays a crucial role in our growth as developers and engineers. This is probably true for every other line of work/study.
>
> [from an earlier writeup](/claude-vscode-extension-learnings#what-about-ancillary-learning%3F)

Some months back, as I was refining [vāk](https://vaak.druchan.cokm) (my custom blog builder that runs my blog and is used by a grand total of 1 user), I was thinking about the fact that almost every decent programmer I know of has gone through this programmer's rite of passage that involves reinventing, for play and more, many little technologies that already have robust implementations.

The ordering may be off (I will touch upon that later) but it goes like this:

- First, you build your own (portfolio) site. Instead of relying on a readymade site-builder (Squarespace/Wordpress back in the day), you would pick something like a framework (ew but Nextjs, or Astro, or some other obscure stuff) and then build your site. Hundreds of hours of theming, customising, integrating with external data-feeds (like your socials or blog) will ensue.
- Then, you level up by porting your journal/blog to a blog-builder of your own. You'll write this in a stack that you're either comfortable with or going gaga about at the time. Hundreds if not thousands of hours will be poured over getting the blog builder just in the right level of abstraction: enough to feel generic (but it's not), but also specific to your use-case in the right way. It's not like anyone else is going to use this but your software-engineering ethics won't let you sleep till you feel it's built like anyone can use it.
- Now, armed with the experience of a blog builder, you will head to writing a parser. If you're ambitious, you'll head straight for the obvious — a JSON parser. If not, you might write something that parses far less of a complicated mess. [Like extracting content inside SQL-code blocks inside documentation files written in Markdown](https://github.com/chandru89new/chequera/blob/main/app/QueryParser.hs).
- Sometimes, it's possible that instead of writing a parser combinator, you might write a library that handles strings of data, either _en mass_ or in a stream. For the nerds, this might come in the form of implementing a protocol (think redis), or, in the case of lesser-nerds, re-inventing git.
- The final boss is when you write a compiler from scratch for a language. This is meta-level at this point: writing a program to eat, grok and execute other programs. [_Crafting Interpreters_](https://craftinginterpreters.com/) is your new bible.

There are some more stages here that very few cross. After the compiler, you might get into [PL-theory](https://en.wikipedia.org/wiki/Programming_language_theory). Philosophising about "what even is _language_? what is _grammar_?" will lead you down a path where you might toy with your own language. There is no chance you won't end up doing a bit of LISPy stuff, or get into ML-like syntax before embarking on your own journey, discovering your own weird syntax.

Or you might branch out into [formal verification](https://en.wikipedia.org/wiki/Formal_verification) if you're into being a stickler (and into math) for proving things _right_ (or _wrong_, if you derive pleasure out of that). You'll possibly get into reading thesis papers more than layman blogposts (like these) and get into stuff that even Haskell engineers at [Bellroy](https://bellroy.com) call "esoteric".

<div class="separator"></div>

The inquisitive will continue to be so. The perpetually-curious who are intrinsically driven to the details and nuances will continue to be so even in the midst of this vibe-coding AI era.

I wonder what will happen to those that would _like_ to skill up but will end up having stunted growth because vibecoding and eager-to-build LLMs are here and the humans are not conscious or aware enough to recognize that the _grind_ (that the LLM eliminates) is what helps skill-up.

<div class="separator"></div>

P.S: The rite of passage is not necessarily sequential. Some folks head straight to _Crafting Interpreters_. Some skip the blog builder and have to write parsers at their job. And some formal verification stalwarts have no skill or craving to build their own site from scratch.
