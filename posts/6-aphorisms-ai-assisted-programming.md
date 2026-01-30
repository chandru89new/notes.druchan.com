---
title: "6 Aphorisms for AI-assisted Pragmatic Programming"
date: 2026-01-16
slug: 6-aphorisms-ai-assisted-programming
status: published
---

_Short aphorisms on AI-assisted (and sometimes AI-driven) software engineering._

###### 1. AI-ludditism is futile

AI-skepticism is fair, AI-ludditism is futile.

AI-assisted programming is here to stay (unless the bubble bursts and leads to prohibitively-expensive tokens).

"AI has sucked the fun out of programming" is a proxy for AI-ludditism. The entrepreneurial programmer (who loves building things and sees writing code as a means to an end) wins while the puzzle-solver (who loves writing code) will be left behind.

###### 2. Balance AI-driven and AI-assisted modes of operation to keep your sanity and your job

AI-assisted mode is when you alternate between driving and navigating, lots of checkpoints, have a close-to-intimate understanding of the code that is getting checked-in.

AI-driven mode is when you let the AI do almost everything, only occasionally pausing to supply a correction, a clarification or a gentle steer.

AI-assisted mode will help us retain our ability to understand, craft, update and refactor programs without atrophy. It gives us a chance to fight back against slop, and craft robust codebases. AI-driven (of which vibe coding is an extreme end) most likely leads to problems of all kinds.

Simple rule: Chores? AI-driven. Otherwise = AI-assisted.

###### 3. Increase your surface area of impact

If AI can work at the level of a mid-engineer, what is our worth to the organization?

AI enables us engineers to increase the surface area of our impact: a frontend engineer can now build a decent first cut of a feature end-to-end, including backend and database changes; a backend engineer can now extend or add new functionality end-to-end, including frontend and doing some DevOps work.

You provide value by expanding the surface area of your impact in the team, organization, product.

###### 4. Bad mental models = Bad instructions = Bad implementation

AI doesn't seem to be able to save you from your bad mental models.

If your internal mental model of a solution is bad to start with, your instructions to the AI reek of bad assumptions, bad directions and bad examples.

The basic tenets of software design remain intact. Simple, correct, safe software starts with simple, correct, safe mental models in the human prompter.

###### 5. Code is still the best documentation, but AI makes grokking easy

Long spec files, implementation.md files and other such gimmicks are trying to be proxies for grokking the code but they all suffer from a plethora of issues (too long to read, outdated and obsolete within days, too many to track etc.).

Code continues to remain the best source of truth for documentation, because code is what runs and code is what lies underneath a running software.

Where AI really helps (in teams) is being able to grok the code. AI can summarize, point out the nuances, and even "reason" about many human decisions in the code.

When working with other people's code, use AI to understand.

###### 6. Use tests, types and immutability to bring back determinism in a non-deterministic world

Generative AI produces non-deterministic outputs. This is especially scary when you let it modify existing code.

End-to-end tests, static type checking and functional ideas like immutability and managed side-effects are the antidotes and safeguards against non-deterministic code fiddling.

E2E tests guarantee the app works as expected for all users. Type checking ensures hallucinated code, hallucinated arguments do not even compile in the first place. And practices like immutability (by using a language that defaults to immutable values) eliminate a class of problems that AI-generated code can bring in (because it has been trained on a lot of human-written code that can be buggy).
