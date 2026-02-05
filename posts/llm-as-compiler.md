---
title: "LLM, the compiler."
date: 2026-01-30
slug: llm-as-compiler
status: published
collections: Programming, LLM in software engineering
---

"The new lingua franca of programming is English."

"I don't look at code anymore. I don't look at diffs."

"There is no way I can look at 3000+ diff patches anymore. It's all spec-driven."

At first, it's a hard thing to grapple with as a cautious optimist. To not look at code anymore, and yet build things that span hundreds and thousands of lines of code, seems reckless.

But what is writing JavaScript or C? The code anyway gets compiled and then "translated" into some lower-level language, eventually becoming assembly instructions. Most programmers today do not "look" at the compiled, assembly code, do we? Did the first generation of higher-level language users who almost never looked at the compiled code get frowned upon by those who wrote assembly programs by hand?

And how is this any different from today? English is the higher-level programming language, the LLM is the compiler.

The one main (and perhaps the only) difference is the non-determinism that emerges out of the fundamental way in which LLMs work (described as a stochastic parrot) vs. the deterministic outputs of compilers and transpilers. Given a piece of code in a higher language, and a compiler with a set of options, the output in assembly or bytecode will always be the same. This is a reassuring thing because this allows us to write formal "correctness" verification programs for the compilers and guarantee that the outputs will be exactly as expected and not do funny things. Doing this in the "LLM-as-compiler" model seems impossible at this time.

But, people just don't care. Businesses and organisations are in a perennial race to ship money-making features all the time and software (the way we do it) has this inherent capacity to be built fast (because there is the possibility of iterative improvements and the cost of a bug or failure is 99% of the time not catastrophic). And this "English as the programming language, LLM as the compiler" model helps in this race.
