---
title: "Claude, RTFM For Me: Building a VS Code Extension in the Age of LLMs"
date: 2025-02-07
slug: claude-vscode-extension-learnings
ignore: false
---

###### TLDR

I built a VS Code extension for the first time using Claude's help all the way. Half-way through this exercise, I wanted to understand VS Code Extension APIs deeper and I realized that grokking the docs takes an order of a magnitude more time than to build a reasonably working extension using LLMs. Plus, a few insights on the evolution of the way we work on side-projects.

###### How it all started

Now that I think of it, I am not even sure how things went from the launch of [DeepSeek](https://www.deepseek.com/) to wanting to build a VS Code extension, but the broad idea must have been this: there's a new open-source model that the hype-train claims to be better than o1, I can run that locally (with caveats of course) and finally, "how about creating my own extension that lets me do what I do in Windsurf/Cursor, except, all of this runs locally and I can customize it the way I want it to?!"

LLM-aided development work has become more or less the norm for me. At work and on side-projects, I make use of both inline code-completions and occasionally full-fledged Cascade-like workflows. My primary IDE, to that extent, is [Windsurf](https://codeium.com/windsurf).

On the free tier, you can only chat with the LLMs (and only Codeium Fast model once you run out of credits); on the paid plans, you can chat with premium models and also use the "Write" option of Cascade which makes edits to your codebase, saving you a lot of time — but these come with limits. Obviously, these are businesses that need to make money.

But given that pro-level models (like R1) are open-source, and the mechanics of running them are easy (e.g, `ollama`), I thought it would be possible to have Cascade-like abilities that run completely offline and are a tad more configurable!

That's how I ended up in this side-project of building a VS Code extension.

Like all side-projects, I knew I'd likely not get very far but I'd at least build my very first VS Code extension!

###### AI Boilerplates are all the rage now

LLMs now take the idea of boilerplates to a new level. Ask Claude 3.5 to help you get started with a VS Code extension (as I did) and, on the first step, it writes for you a bunch of files that get you more than just started.

###### 0 to 100 in X minutes

Within minutes, a _functioning_ VS code extension was ready. I had few annoying moments trying to understand how to get the extension to run because there were build errors (the extension was scaffolded in Typescript and `esbuild`) but Claude was helpful here too.

In a handful of further iterations, I had an extension where you could open the Chat inside VS Code, type a question and have it answered by the LLM running on your machine via `ollama`. In my case, I had the 7b variant of DeepSeek-R1 running. (The answers were weird and bad, maybe in keeping with the model I chose, but that's for another time.)

###### A strange fear sets in

Even though I had a bare-minimum prototype, I was feeling queasy because I did not understand much of the "webview" parts of the code. There was some registration thing going on, some class-like mechanics etc.

The thing with LLMs is that it gives a false sense of accelerated self-learning. There is a big difference between knowledge, especially the kind of one-shot answers you learn when you troubleshoot a bug or learn the use of an API, and wisdom where you gain a context-enriched, broader understanding of a thing, sometimes extending to the generalized/abstract idea.

In chatting with Claude and building the bare-minimum prototype, I gained some knowledge of how to get started and what areas to tinker with to get the desired result, but I had no clue of the bootstrapping parts of the code that called a plethora of Extension API functions.

So, I decided to dig into the manual.

###### There was an attempt to grok the manual

I spent 2-3x more time going through the docs than I spent building the bare-minimum prototype.

Not that the docs are dense but some of the fundamental pieces in understanding the underlying logic of the APIs are missing in my knowledge base. I realize this is because I did not follow one of the "traditional" modes of grokking a documentation — one that involves skimming through the basics/introductions which talk about the philosophy behind the API, following it up with deeper dives into the relevant parts of the API. Instead, I just let the LLM guide me and LLMs do not necessarily guide you all the way from the basics (unless asked specifically to do so).

###### With LLMs, learning by doing is now supercharged

I learn in two ways.

One: learn by doing. Just pick a tool, a bootstrapped project or a starter pack, start hacking around in an attempt to build something (or solve something) and learn in that process. Learning is a byproduct, often a conscious one, of doing. This is how I learnt a lot of things in life: HTML, CSS, jQuery, JavaScript, Vue, MeteorJS, pub-sub, etc.

Two: learn the ropes, the fundamentals and build my knowledge-base while reinforcing that learning by doing things. Doing things here is secondary. This is how most of my knowledge of Elm, Haskell, monads, basics of German language, the teeny-tiny bit of income tax know-how etc have come about.

LLMs have made the first kind of learning — learning by doing — supercharged. Good LLMs are able to help us bootstrap faster, cross hurdles quicker (with good explanations of underlying or fundamental ideas behind idiomatic solutions, if prompted well), and reach faster the very same hurdles and pitfalls that promote learning because you get to do a lot more, lot quicker with the help of LLMs.

###### There's still lots of room to question the basics

But LLMs are frequency machines in their simplest distillation. Claude set me up with a bootstrap for the extension codebase in the way thousands (if not millions) of tutorials teach you to, because it has been trained on such documents. So when I asked why there are these superfluous-looking JSON files (eg `tasks.json`, `settings.json` etc.), and if they can be removed, it had to come from questioning the basics and going for simplicity.

This is a pattern that repeats often. We (as humans) are not designed to naturally seek or gravitate towards the simplest solution (entire industries have emerged and thrive on the specialization of being able to find a sleek, simple solution to complex problems). LLMs aren't designed to offer the simplest solutions either.

So it is upon you and me to find a way to make LLMs question the basics of their own approach (ie, their answers to our prompts). At some point, the larger context-size LLMs will be able to remember to adapt to a person's preferred _style_ of answers sought all the time and then it may not be necessary to "question the basics" on behalf of the LLM. Till then, it's necessary to intervene and remind the LLM to go for the simpler approach, and question it because it will pick the popular approach (that often may not be what you need).

###### What about ancillary learning?

There is one other thing that I miss the most.

When you go down the rabbit hole of a bug in the pre-LLM, traditional way (eg, StackOverflow), you end up picking up a variety of ancillary tidbits of information (and sometimes wisdom) that may not be directly related to what you're looking for, but in an adjacent space.

LLMs, on the other hand, are trying to give you the sharpest, closest solution possible. When learning through an LLM (especially around bug triangulation, troubleshooting etc), there is hardly any room or potential for ancillary learning.

Although I have no data on this, I tend to believe that ancillary learning plays a crucial role in our growth as developers and engineers. This is probably true for every other line of work/study.

Unless you spend time crafting the right kind of exploratory, non-optimal prompting that is not driven by the dictates of time and capitalist requirements of work, you'd hardly ever get to expose yourself to the "ancillary knowledge". There isn't an algorithm for this; it's very randomized and you can't "temperature" control this as far as I can see.

###### Extension's future

I haven't worked on the extension since the last commit last weekend. Unlike [rdigest](https://github.com/chandru89new/rdigest) (which I started using everyday even by the first iteration), this extension is not something I'd use in its present shape, nor in probably 2-3 more iterations.

To extract decent value out of it, it needs to run on the latest 400gig model of DeepSeek-R1 with more RAM on my machine. Even the 40gig model is very slow for me. Plus, I'd need to add file attachment capabilities, nicer system prompts and a whole lot. I don't think I have the time or the inclination to do that.
