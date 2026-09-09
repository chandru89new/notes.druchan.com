---
title: "work.patch"
date: 2026-09-06
slug: work-patch
status: published
collections: LLM in Software Engineering
---

By the time I was fully into software programming, `git` had become the de-facto abstraction to managing codebase changes and collaborate. The days of writing and exchanging "patches" and diffs with others before applying them upstream had long since disappeared (except maybe in some small quarters within the Linux kernel ecosystem).

LLMs have changed that for me. I am back to what can be called "diff-driven development". It's one way I can retain my sanity, reduce my stress-levels and get work done with Claude.

I've been using LLMs to assist in writing programs since about 2023. Back then, working with AI (specifically to write programs) was like working with an intern: wrong data models, bad assumptions, convoluted code. In 2026, LLMs have become very powerful and all-consuming. Now, they have no human equivalence: highly complex data models, all-encompassing assumptions that try to factor every edge-case there is, and naturally, convoluted code.

My own workflow has evolved from using AI to just ideate, find facts and research (glorified, more-focused, occasionally-wrong search engine) to now letting them write code. I tried doing the thing many of my peers do: let it mutate the codebase directly, piling up many changes before raising that dreaded pull-request that a human has to read but I've never been happy about that. It's okay for trivial changes, and a disaster for non-trivial ones. Despite the glowing reviews we hear about the capacity of these frontier models, my experience with large-scale, autonomous changes after giving a detailed spec is still bad. The RoI on crafting the spec after much back-and-forth is completely unjustified.

Of late, there have been other compounding problems. Claude speaks in a style of prose that's famously annoying. "Two reasons, and both point to the same load-bearing cause", "Not intentional, just accidental", "One caveat I'd pay attention to: ...", and other such Claudisms have become staple. And the incessant need for jargon — both made-up and existing ones — is such a pain to read.

I've also found it increasingly incomprehensible to read large paragraphs of text (replete with file names and line numbers), interspersed with code fragments. On a well-crafted LaTex paper, this is fine, but in the confines of a terminal window, especially with the amount of varied branches that LLMs try to encapsulate in a single change, it slows down both my comprehension and the ability to connect the changes to the larger context of the codebase, engineering practices and my own quest to reach for the simple.

In recent times, I've changed my workflow.

I've got Claude to stop talking in that ingratiating style of prose and instead "speak properly". That means complete sentences, and all avoidance of Claudisms. This is a memory that it loads at the start.

I've also got Claude to split code from prose. Barring an occasional one-liner, all code that Claude wants to show me (for my review) goes in a `work.patch` file in the directory. All ideation back-and-forth goes in the terminal with Claude but whatever changes are proposed thereafter in terms of code are written to a `work.patch` file. I examine the diff in the patch file, make corrections or instruct Claude and iterate through the patch file before applying it.

My settings also prevent Claude from directly affecting the files even in auto-mode. Any change it proposes to do has to go through the patch-file.

At the end, it's all a diff, yes, and sometimes the summation of those diffs is large for a pull request. But I cannot start from a large diff and work through its parts; instead, I like to start from small diffs and accumulate them.

The corollary to this feels true too. If you've had to review a reasonably mid/large-sized pull request, specifically in the traditional interface of GitHub or others, you are looking at a mishmash of changes. Some changes to a file make no sense unless you correlate them to a change several files down the list. (eg, a modification in a function, or a new function exported). Commits used to be a good way to chunk-up the changes in logical batches. Each commit told a story of a change, a subsequent commit improved upon it, fixed a bug in the previous one, or added a new chunk of feature/fix. But people seldom use commits that way now.[^1]

So, I ask Claude to pull the PR patch (the diff of the PR that we see on GitHub) and chunk it into related changes[^2]. This gives me a better sense of the changes in logical sequence and also, smaller chunks of diffs to review. It's not always a beneficial activity: sometimes, I just have to look at the whole thing in context. But when it works, it works very well.

What does all of this mean? Lowered gains in productivity. It's funny how often we treat lowered gains as a loss but relatively, it's still some gains. What I trade that deficit for is lot more clarity about the work I do, about the code change that goes upstream, and definitely far less strain on the brain to grok stuff others write.

[^1]: Let's say you make three commits (A, B, C) as part of a changeset. Turns out A had a bug. We used to update A. We don't do that now; we just write a new commit D. This breaks the "commit as a story of logically-grouped changes".

[^2]: It is certainly insane how "smart" LLMs can be in this regard. Claude can split a large PR into the most logical series of commits/patches and reconstruct a better story than what the developer did.
