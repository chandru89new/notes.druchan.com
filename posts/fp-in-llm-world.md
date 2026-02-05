---
title: Functional programming in an LLM world
date: 2026-02-03
slug: fp-in-llm-world
status: published
collections: Functional programming, LLM in software engineering
---

A twenty-something and their ChatGPT has produced a code artefact that is currently in production. Somewhere deep in the code soup, there is this utility function...

```js
function calculateShipping(weight, distance, isExpress) {
  const baseRate = 5.99;
  const weightRate = weight * 0.5;
  const distanceRate = distance * 0.1;
  const expressMultiplier = isExpress ? 2 : 1;

  return (baseRate + weightRate + distanceRate) * expressMultiplier;
}
```

...which then seems to get called in some other part of the codebase like so:

```js
function processOrder(order) {
  const subTotal = order.items.reduce((sum, item) => sum + item.price, 0);
  const shipping = calculateShipping(order.weight, order.distance);
  return { total: subTotal + shipping, shipping };
}
```

About a week later, customers are complaining that express orders are not being charged the express rates.

The fix is easy, sure, but it's 2026. How come we're still making these errors to begin with?

\*

In the 1970s, a lot of smart programming-language scientists and academicians **wrote up a bunch of ideas about constructing, describing and writing programs in a way that was different** to the then-typical [_von Neumann-style_](https://en.wikipedia.org/wiki/Von_Neumann_architecture) (i.e, imperative-style) of programming.

The idea was not just to be smart, of course. They wanted to write programs in a way that was **easier to _reason_ about**, easier for mathematicians to come in and prove the correctness of the programs and, in some weird way, **useful for programmers because it let them not worry about silly errors that were common in the other, _imperative_-style of programming.**

These ideas have long since escaped the confines of academic esotericism and joined the mainstream through languages like Haskell and OCaml, and also been adopted into many languages including Rust, Swift, Java, Javascript and more.

What's the point of it all?

Well, **it's baffling that we continue to produce the same class of errors that we've been producing** — now, even with AI-generated code — despite the fact that hundreds of smart folks helped found ideas and mechanics of eliminating those entire classes of errors from our programs.

**Things like _undefined_ and _null-pointer errors_, things like missing a case in a switch/pattern-match (looking at you Typescript), things like totality, things like using generic _string_ types where a branded-type (custom data-type) would do a much better job of catching errors early**... you know, just things that make software robust, safe and error-free.

As humans we made these errors in our codebases. These trained the AI models. Now AI generates similar errors, even if not in as much quantity and frequency. AI is getting better, yes, and there are fewer instances of such errors but the very idea that such errors continue to crop up is supremely silly.

\*

Let's take the case of **static typing**.

A lot of languages are dynamically typed and going strong: Python, Javascript, Clojure. But each seemingly has a superset or a library add-on that adds, to varying degrees of robustness, some kind of a type-system. Heck, **an entire superset of Javascript spawned because programmers believe having types and type-guarantees is _good_**.

But even Typescript only goes so far. And the rest, like Clojure Spec or Pydantic, go far less. On the other hand, **strongly type-driven languages like Haskell, Elm and OCaml travel the farthest when it comes to guaranteeing a hell lot of safeties and bug-free programs at conception**.

When AI generates dynamically-typed code, you need an elaborate set of unit tests (or property-based tests) to ensure the functions work as expected and handle cases when the input types are wrong. But **when AI generates code in a strong, statically-typed language, a formidable set of static compilation checks (or a language server) ensures that the function implementation makes no mistakes** with the input and output types.

Consider a function that adds money:

It's insufferably easy to get it wrong in Javascript:

```js
const addMoney = (a, b) => a + b;
let a = 24.0; // in EUR
let b = 26.0; // in USD

addMoney(a, b); // makes no sense to add EUR and USD
```

Typescript introduces a way of safeguarding. It is convoluted, but it works.

```ts
type EUR = number & { readonly __brand: "EUR" };
type USD = number & { readonly __brand: "USD" };

const eur = (amount: number): EUR => amount as EUR;
const usd = (amount: number): USD => amount as USD;

const addEUR = (a: EUR, b: EUR): EUR => (a + b) as EUR;
const addUSD = (a: USD, b: USD): USD => (a + b) as USD;

let a = eur(24.0);
let b = usd(26.0);

addEUR(a, a); // ✓ works
addEUR(a, b); // ✗ Type error: USD not assignable to EUR
```

Here's Haskell, a pure-functional programming language:

```haskell
newtype Money (currency :: Symbol) = Money Double

eur :: Money "EUR"
eur = Money 24.00

usd :: Money "USD"
usd = Money 26.00

addMoney :: Money c -> Money c -> Money c
total = addMoney eur usd  -- ERROR: "EUR" ≠ "USD"
```

The compiler, armed with all the historic logic of strong type-checking, will prevent the code from even compiling in the first place.

With a decent LSP-LLM integration, which is now very common among the top-AI players, **these kinds of bugs are caught even as the AI tries to produce code**, and fed back into the AI to correct itself.

> There are many ways of trying to understand programs. People often rely too much on one way, which is called “debugging” and consists of running a partly-understood program to see if it does what you expected. Another way, which ML advocates, is to install some means of understanding in the very programs themselves. - _Robin Milner_.

Types are not just mechanisms to create safe programs. They are **useful to _construct_ programs from scratch**. Types are not just those things you use to set guardrails around how functions are called; they are the basic building blocks. These building blocks **allow us to trace and understand programs far better than slapping a million debug statements** and running through them tediously.

All the tooling and mechanics around this is already present. We just need to ask the AI to write programs the way functional programmers write programs: start with types, write the functions around them, and construct entire systems by putting together the pieces... by "composing".

Nowhere is this made more natural than in languages that support, inherently, the ideas of functional programming. In every other language where these ideas are an afterthought and therefore an add-on package, **it is very easy for AI to escape-hatch itself and default to "just make things work" mode which can result in code that is peppered with errors**.

\*

They go by many names. Arrays, lists, vectors, slices, collections. The earliest reference to lists as a formal, mathematical concept appears at around 200 B.C. Computer science, which happens to rely so much on math, implemented arrays in the 1940s and 1950s.

In 2026, **your app will crash if you have, anywhere in the code, `array[1]` and the `array` happens to be empty, or worse, a pointer to nothing.**

The funny thing about this is that **it doesn't matter what industrial-power language you pick: Golang, Python, Javascript (and even Typescript sometimes). Everyone will fail you.** And the mistake is so prevalent across thousands of codebases that it would be almost impossible for AI not to have trained and reinforced on such ugly, disastrous patterns.

In FP, it is _unidiomatic_ to access an index in a list. It is totally do-able, but most programmers prefer the _idiomatic_ way, which involves a mild tedium called _pattern matching_.

```haskell
at :: [a] -> Int -> Maybe a
at [] _ = Nothing
at (x:_) 0 = Just x
at (_:xs) n = at xs (n - 1)

-- or, better, using Vectors
at' :: Vector a -> Int -> Maybe a
at' v idx = v `!?` idx
```

There's a lot of things happening here, described syntactically, that create near-perfect conditions for the code to not break, crash or go crazy. The `at` function tries — that's an important keyword here, _tries_ — to extract the *n*th element in a list. The three lines are pattern-matches that cover all possible cases: the list is either empty or has at least one element. If your code did not have any one of those lines, the compiler will prevent you from compiling the code. And the result of this extraction is not a guaranteed value of `a`. It's `Maybe a`, meaning, **if the list was empty to begin with, you extract `Nothing`. Downstream, when this function is used on a list, you have to contend with the `Nothing`.** That is, you have to tell the program what to do if the extraction resulted in `Nothing`.

```haskell
getPrimaryEmail :: List String -> String
getPrimaryEmail emails = case at emails 0 of
    Just email -> email
    Nothing -> "noreply@nomail.com"
```

Why is this useful? **Why is this important?**

Thousands of programs have been written this way in functional languages with strong type inference. That means the data that trained the LLMs has this pattern repeat over and over again. And so, **when you ask an LLM to write a Haskell or a Rust program dealing with lists, it emerges with safe code paradigms** like these making your programs safer, eliminating a class of old, pesky bugs.

\*

It is quite possible that LLMs eliminate hallucinations entirely. It is also possible (and perhaps happening) where LLM offers a pseudo-determinism in a lot of cache-able (or skill-able) actions, like when we ask it to "write a function to test for prime."

But **the inherent non-determinism of output when asking it do something complex remains. That's not a bug, that's a feature.** "Write a program to handle a notification queue that is extensible to multiple notification channels," is a wide-ranging ask that will produce a different kind of a code every time you ask the LLM. With each iteration, there may be plenty of sneaky bugs like the ones outlined above (and more).

"But we have tests!" — yes, tests are quite possibly the finest ways of guaranteeing a program. The formal verification specialist tells me it's not true; formal verification is the surest way. But a majority of the industry doesn't spare any time or resources on formal verification of their programs. **So tests are currently our _only_ means to ensure an app works as intended** despite an onslaught of vibe coded slop entering the production lines.

But **imagine having to write tests to ensure somewhere in the codebase a function is not called with the wrong parameter type** or an array's non-existing index is accessed. A whole class of errors are already "catch"-able at compilation; a whole class of human fallacies are already addressed thanks to the work of computational and mathematical geniuses. And not using that seems ridiculous.

\*

Functional programming is not an easy paradigm to master. The steep learning curve ([and the monads](/should-i-learn-monads)) have kept a lot of people away, and in fact driven them (back) into the arms of OOP.

But with LLMs, the slope of this curve can come down drastically. **Generative AI for code and engineering reduces the need for absolute mastery in a functional language but allows us to reap the benefits of the guarantees and safety**. It's not yet a perfect balance but it has the best chance of getting there.

A hell lot of code is going to get generated using LLMs this year. Till the bubble pops when AI companies increase their token prices to realistic values, **organisations are going to build larger throughput pipelines directly from LLM out to production codebase**. The cost is not just the tokens and the prompt engineers. **The cost is all the slop and the many classes of bugs that are going to get introduced** which will then need really good engineers (along with AI) to fix. And don't forget the time spent on doing that.

Part of picking the right stack is picking good, sound languages to build things with. And now might be the best time for software engineers to add FP languages to the stack to reap engineering benefits of academic rigour.
