---
title: Re:Paper 001 — Can Programming Be Liberated From von Neumann Style?
date: 2026-08-07
slug: re-paper-001
status: published
collections: "Re-Paper"
---

_Re:Paper_ is a pet project where I get to read interesting papers from the past and share my thoughts/impressions. It's not too dissimilar to book reviews, except for papers or talks that get published as papers.

For 001, we have [_Can Programming be Liberated from von Neumann Style_](https://dl.acm.org/doi/10.1145/359576.359579) by [John Backus](https://en.wikipedia.org/wiki/John_Backus).

I have no idea how I landed on this paper or from where. But I'm certain that it must've come about from my daily meanderings in the functional-programming world (subreddits, discourse, some random FP slack channel etc.).

I think it was good that by the time I discovered this paper (which is a written-up version of a talk at the ACM), I had dabbled in functional programming, written a few programs, and gotten completely smitten by this paradigm. That definitely helped in appreciating (and to a reasonable degree, understanding) what Backus was talking about.

<div class="separator"></div>

It feels both pertinent and absolutely useless to be talking about the structure of programming languages when AI/LLMs are hard at work trying to invalidate most of these things by making production of code and code artefacts cheap (in terms of effort involved, not the actual money spent on tokens).

But what I like about this paper/talk is a couple of levels more fundamental (and universal) than functional programming vs conventional programming. It's Backus's inherent thrust towards reduction, towards simplification and towards arriving at programming structures that are simple (in the [_Rich Hickey_ way](https://www.infoq.com/presentations/Simple-Made-Easy/)).

If I were to reduce the paper/talk, it's this:

- conventional programming languages are complex and not very flexible.
- even newer languages of his time follow the same philosophy of other conventional languages because they all spring from a near-universal architecture of computers themselves: the von Neumann architecture.
- in the conventional world, programs are a chaos of expressions and statements (Backus clearly prefers the former) and statements are inherently disorderly and unwieldy.
- a lot of the language is about storing, naming, retrieving data instead of being about the core logic of the computation itself.
- and the languages have very limited, frozen expressive power: the constructs are already built-in, and extensibility is almost non-existent.
- the paradigm he puts forth is "functional-style" where one combines forms (ie composition of functions) so more complex programs can be built from simpler programs (big on extensibility), don't have to name their arguments (point-free), and has a familiar algebra-esque appearance so there is not much of a distinction between the syntax and the logical expression. They're almost the same. Less cognitive load.

<div class="separator"></div>

The first thing to know is that these incensed debates on programming languages is not of a recent making. Python vs Javascript and Rust vs Zig are just continuing a tradition that Backus equates to medieval debates:

> Discussions about programming languages often resemble medieval debates about the number of angels that can dance on the head of a pin instead of exciting contests between fundamentally differing concepts.

Backus's primary dig is at what he terms as the "von Neumann-style" of programming that has its intellectual genesis in the _von Neumann architecture_<sup>1</sup>.

All the way from Assembly to Fortran (which Backus created/spearheaded), this architecture has influenced how we think about programming and how people think about the syntax and structures of a programming language.

> [the von Neumann architecture consists of](https://en.wikipedia.org/wiki/Von_Neumann_architecture) three parts: a central processing unit (or CPU), a store, and a connecting tube that can transmit a single word between the CPU and the store (and send an address to the store). I propose to call this tube the _von Neumann bottleneck_. The task of a program is to change the contents of the store in some major way; when one considers that this task must be accomplished entirely by pumping single words back and forth through the von Neumann bottleneck, the reason for its name becomes clear.
>
> Ironically, a large part of the traffic in the bottleneck is not useful data but merely names of data, as well as operations and data used only to compute such names.

That is, a lot of the code and syntax is about the assignments, the loops, the busywork of storing and retrieving data instead of the core logic of the program itself:

> Thus programming is basically planning and detailing the enormous traffic of words through the von Neumann bottleneck, and much of that traffic concerns not significant data itself but where to find it.

This "traffic" gets expressed as assignment statements which splits the world into two: statements and expressions:

> von Neumann languages also split programming into a world of expressions and a world of statements; the first of these is an orderly world, the second is a disorderly one, a world that structured programming has simplified somewhat, but without attacking the basic problems of the split itself and of the word-at-a-time style of conventional languages.

The most common "statement" is the assignment statement which itself is a combination of a statement and an expression.

```
c := c + a[i] * b[i]
```

> Moreover, the assignment statement splits programming into two worlds. The first world comprises the right sides of assignment statements. This is an orderly world of expressions, a world that has useful algebraic properties (except that those properties are often destroyed by side effects). It is the world in which most useful computation takes place.
>
> The second world of conventional programming languages is the world of statements. The primary statement in that world is the assignment statement itself. All the other statements of the language exist in order to make it possible to perform a computation that must be based on this primitive construct: the assignment statement.

To Backus, the world of statements is unwieldy, does not lend itself to mathematical or logical scrutiny.

> This world of statements is a disorderly one, with few useful mathematical properties. Structured programming can be seen as a modest effort to introduce some order into this chaotic world, but it accomplishes little in attacking the fundamental problems created by the word-at-a-time von Neumann style of programming, with its primitive use of loops, subscripts, and branching flow of control.

Backus also focuses his criticism on the idea that conventional languages are rigid structures and offer very limited changeable parts. There's no scope for composition (_combining forms_), and the state transition rules are all built into the framework itself so the user has to just play by the rules and cannot invent new forms.

> A programming language comprises a framework plus some changeable parts. The framework of a von Neumann language requires that most features must be built into it; it can accommodate only limited changeable parts (e.g., user-defined procedures) because there must be detailed provisions in the "state" and its transition rules for all the needs of the changeable parts, as well as for all the features built into the framework. The reason the von Neumann framework is so inflexible is that its semantics is too closely coupled to the state: every detail of a computation changes the state.

Backus takes the case of the "inner-product". Here's the conventional program and Backus's criticism of it:

```
c := 0
for i := 1 step 1 until n do
   c := c + a[i]×b[i]
```

> Several properties of this program are worth noting:
>
> a) Its statements operate on an invisible "state" according to complex rules.
>
> b) It is not hierarchical. Except for the right side of the assignment statement, it does not construct complex entities from simpler ones. (Larger programs, however, often do.)
>
> c) It is dynamic and repetitive. One must mentally execute it to understand it.
>
> d) It computes word-at-a-time by repetition (of the assignment) and by modification (of variable i).
>
> e) Part of the data, n, is in the program; thus it lacks generality and works only for vectors of length n.
>
> f) It names its arguments; it can only be used for vectors a and b. To become general, it requires a procedure declaration. These involve complex issues (e.g., call-by-name versus call-by-value).
>
> g) Its "housekeeping" operations are represented by symbols in scattered places (in the **for** statement and the subscripts in the assignment). This makes it impossible to consolidate housekeeping operations, the most common of all, into single, powerful, widely useful operators. Thus in programming those operations one must always start again at square one, writing "**for** i := ..." and "**for** j := ..." followed by assignment statements sprinkled with i's and j's.

So what's Backus's solution?

By this time (1978), computing has seen two or more new ideas come into the academic mainstream. Church's Lambda calculus and APL were influential in Backus's proposal.

> An alternative functional style of programming is founded on the use of combining forms for creating programs. Functional programs deal with structured data, are often nonrepetitive and nonrecursive, are hierarchically constructed, do not name their arguments, and do not require the complex machinery of procedure declarations to become generally applicable. Combining forms can use high level programs to build still higher level ones in a style not possible in conventional languages.

In Backus's FP, the inner product is this:

```
Def Innerproduct
    ≡ (Insert +)∘(ApplyToAll ×)∘Transpose
```

> Or, in abbreviated form:

```
Def IP ≡ (/+)∘(α×)∘Trans.
```

> Composition (∘), Insert (/), and ApplyToAll (α) are _functional forms_ that combine existing functions to form new ones.

ApplyToAll is essentially `map`. Insert is `reduce` (although, more technically, it's `reduceRight`). Composition has no JS equivalent but it's fundamentally the `compose` function from [Ramda](https://ramdajs.com/docs/#compose)/[Sanctuary](https://sanctuary.js.org/#compose).

How does this definition work?

Transpose takes two vectors of arbitrary length and "transposes" them:

```
Transpose:<1,2,3> <4,5,6> = <<1,4>,<2,5>,<3,6>>
```

ApplyToAll applies the binary `×` to each vector:

```
ApplyToAll ×: <<1,4>,<2,5>,<3,6>> = <<1×4>,<2×5>,<3×6>> = <<4>,<10>,<18>> = <4,10,18>
```

And finally the Insert:

```
Insert +: <4,10,18> = 4 + 10 + 18 = 32.
```

Right away, we can notice a few things about this program:

- no arguments specified. [Point-free](https://en.wikipedia.org/wiki/Tacit_programming). The functions work on vectors of arbitrary length. Eliminates that `n` from the conventional program,
- The whole logic is built from smaller functions by way of composition. That's what Backus calls _combining forms_;
- no hidden states (`n`, `i`, accumulating `c`).

In the paper, he explains the benefits:

> a) It operates only on its arguments. There are no hidden states or complex transition rules. There are only two kinds of rules, one for applying a function to its argument, the other for obtaining the function denoted by a functional form such as composition, *f*∘*g*, or ApplyToAll, αf, when one knows the functions _f_ and _g_, the _parameters_ of the forms.
>
> b) It is hierarchical, being built from three simpler functions (+, ×, Trans) and three functional forms *f*∘*g*, α*f*, and /_f_.
>
> c) It is static and nonrepetitive, in the sense that its structure is helpful in understanding it without mentally executing it. For example, if one understands the action of the forms *f*∘*g* and α*f*, and of the functions × and Trans, then one understands the action of α× and of (α×)∘Trans, and so on.
>
> d) It operates on whole conceptual units, not words; it has three steps; no step is repeated.
>
> e) It incorporates no data; it is completely general; it works for any pair of conformable vectors.
>
> f) It does not name its arguments; it can be applied to any pair of vectors without any procedure declaration or complex substitution rules.
>
> g) It employs housekeeping forms and functions that are generally useful in many other programs; in fact, only + and × are not concerned with housekeeping. These forms and functions can combine with others to create higher level housekeeping operators.

The fundamental idea that Backus keeps coming back to, with his push for functional programming, is this:

> ... programs can be expressed in a language that has an associated algebra. This algebra can be used to transform programs and to solve some equations whose "unknowns" are programs, in much the same way one solves equations in high school algebra.

Interesting note: recursion is already baked into the definition of the formal representation of a functional program expression:

```
Def l ≡ r
```

> where the left side _l_ is an unused function symbol and the right side _r_ is a functional form (which may depend on _l_).

What about "state" that Backus said conventional programs make complex?

Pure expressions are generally not useful by way of programs. A program has to do something (think, side-effects like writing to the disk, thereby changing some form of a global state of the system).

If you're familiar with ideas of [Redux](https://redux.js.org/) (which has its ideological roots in Elm's [TEA](https://guide.elm-lang.org/architecture/)), Backus's words might ring familiar:

> Unlike von Neumann languages, these systems have semantics loosely coupled to states-only one state transition occurs per major computation.

> The applicative subsystem cannot change the state D and it does not change during the evaluation of an expression. A new state is computed along with output and replaces the old state when output is issued.

Here, Backus is proposing something of the form:

```
State -> (Value, State)
```

That is, there's a global state. The functional program does nothing to it. It _uses_ the global state, to compute a new one, along with an output. When the computation is done, it replaces the old state with the new one. So that's, approximately in 1978, when the ideological seed for the [State Monad](https://wiki.haskell.org/index.php?title=State_Monad), [TEA](https://guide.elm-lang.org/architecture/) etc are sown.

Backus does this because this form, or this idea, lends itself better to algebraic scrutiny, formalization and even composition.

<div class="separator"></div>

All said and done, the von Neumann architecture is still kind of the bedrock of our computers. And that paradigm continues to have its influence across languages.

But somewhere, a consortium of ideas like applicative-style, strong structural types, algebraic systems of expressions etc. have seeped enough to influence a new crop of programming languages in recent times.

Credit for some parts of that certainly goes to John Backus.
