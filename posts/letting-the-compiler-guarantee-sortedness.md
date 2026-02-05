---
title: "Letting the compiler guarantee sortedness"
date: 2025-09-29
slug: letting-the-compiler-guarantee-sortedness
status: published
collections: Functional programming
---

It's not often that I wake up on a Sunday and the first thing my brain thinks of is a leetcode problem from two years ago. In fact, it's never. Until today.

I woke up and found myself mulling over a "gotcha" that I left unaddressed back in June 2023 when solving a fine little leetcode problem.

The tl;dr of the problem is you're given a list of stock prices for subsequent days and you have to find the maximum profit possible if you bought and sold the stock at most twice. That is, if you had a stock price list of `[ 3, 1, 0, 0, 1, 2, 3 ]`, the best you can do is buy on the 4th day (for ₹0) and then sell it on 7th day for ₹3, you make a profit of ₹3. (There are some constraints here: you can only buy or sell on a given day; you cannot buy more unless you sell etc. [Check out the writeup for more info](https://notes.druchan.com/max-stock-profit-leetcode))

###### SortedArray type is not all that safe

The solution I managed to cook up worked well but one of the flaws it had was something to do with sorted arrays. In the solution, I needed a _sorted_ array of elements (elements here being some kind of pairs/tuples). In order to ensure some of the functions only allowed a sorted array (and guaranteed this at the type-level), I created a new type called `SortedArray` which, parameterized, looked like this:

```hs
newtype SortedArray a = SortedArray (Array a)
```

The problem was, I could construct a `SortedArray` but it could end up being completely unsorted. I just had to do this:

```hs
totallyMisleading = SortedArray ([7,6,5,7,2,0])
```

If I had to actually make a true-to-its-name `SortedArray`, I had to do this:

```hs
betterArray = SortedArray (sort [5,4,2,8,1,9,8])
```

It still doesn't prevent me from doing `SortedArray (unsortedArray)` which is a disaster waiting to happen.

**Making it impossible to construct a SortedArray unless you use a function**

The way to prevent this from happening is to prevent `SortedArray` constructor from being usable. That is easy: we put this `SortedArray` in a new module and only export the type.

```hs
module SortedArray (SortedArray) where
import Prelude

newtype SortedArray a = SortedArray (Array a)
```

Now, we add a specific function that generates a `SortedArray` from any array:

```hs
import Data.Array (sort)

toSorted :: forall a. Ord a => Array a -> SortedArray a
toSorted xs = SortedArray (sort xs)
```

You could, at this point, go: what's that `Ord a` thingy?

###### Custom data types are not really sortable... unless we tell the compiler so

The key function here is the `sort` which is the default "array sort". The expression `sort xs` works only because we tell the compiler, through the annotation, that whatever elements we're dealing with in the array are "orderable" (through that `Ord a` constraint in the type declaration).

So this will work out of the box:

```hs
sortedNumbers = toSorted [4,3,5,2,6]
-- sortedNumbers == [2,3,4,5,6]
```

But in my original solution, I was dealing with custom data types. Like these:

```hs
data StockDay = StockDay Int Int
data BuySell = BuySell StockDay StockDay
```

An array of elements of these kinds does not lend itself to be sorted.

```hs
sort ([StockDay 1 2, StockDay 3 4, StockDay 1 5])
-- Does not compile.
```

The reason is that `Ord a` constraint. The compiler does not know how to order an array of `StockDay`s or `BuySell`s because there is no `Ord` implementation for these data types. In English, the compiler just doesn't know how to compare two `StockDay`s or two `BuySell`s. If it knew that, it would know how to sort an array of `StockDay`s or `BuySell`s.

So, all that was left was to write some `Ord` instances for these two custom data types:

```hs
instance ordStockDay :: Ord StockDay where
  compare = sortStockDay

instance ordBuySell :: Ord BuySell where
  compare = sortBuySell

-- implementations of these sort functions are cut for brevity
-- sortStockDay :: StockDay -> StockDay -> Ordering
-- sortBuySell :: BuySell -> BuySell -> Ordering

derive instance eqStockDay :: Eq StockDay
derive instance eqBuySell :: Eq BuySell
```

(The `Eq` instance derivations are required in order to be able to write `Ord` instances for those data types.)

With these small changes, I could refactor pertinent bits of the code to get a type-level, compile-time guarantee that whatever function needed to use a `SortedArray` was getting a sorted array for sure.

<div class="separator"></div>

###### Mucking about in other languages

Typically, these posts conclude with a sentence or two about how great this typeclass-supported polymorphism is and how you could reap the benefits mostly in languages like Haskell/Purescript (or OCaml and maybe Rust).

But in digging a little deeper into how other languages would implement a type-level guarantee of array sorted-ness even for custom data types and interfaces, I learnt that many languages support these kinds of shenanigans almost out of the box.

Mostly, it's a matter of declaring the custom "compare" functions for the custom data types and then passing it to the constructors that construct the `SortedArray` type.

Some allow you to "auto-derive" the sorting if the underlying types already have comparison methods defined in the standard library. For example, a Tuple/Pair. Haskell/Purescript allows us to auto-derive too but auto-derived instances for tuples and custom data types can be tricky. They can be tricky for strings too (should I compare strings lexically or by length?). The key concept here is defining what is a "comparison" is hard for some kinds of data where you have more than one dimension on which you can compare.

In these implementations, a pattern emerges. We define a custom compare function for the custom data type, then that is passed to the constructor.

###### Are you passing the comparator implicitly or explicitly?

When I say that's passed to the constructor, there are two ways this happens. Either it's explicit: that is, the custom compare function is passed as an argument to the constructor. Or it's implicit: the custom compare function is nowhere in the construction arguments but because a comparison method is available and associated with the datatype, the compiler (or the runtime) knows what to do, how to sort etc.

In the following examples, assume two things

- we have written a constructor that would construct a `SortedArray`. The interface of this constructor will either need explicit passing of the compare function or not.
- the code is not exactly correct. It exists more as an approximation, for illustrating how one gets things done in the langauge.

For instance, here's Typescript, an explicit beast:

```typescript
type SD = { price: number; day: number };
type BuySell = { first: SD; second: SD };

// Custom comparators
const compareSD = (a: SD, b: SD) => a.price < b.price;
const compareBuySell = (a: BuySell, b: BuySell) =>
  a.second.price - a.first.price < b.second.price - b.first.price;

// Constructors; assume "SortedArray" is some class-like implementation that has a "from" method
// from: <T>(T[], compareFn: (a:T,b:T) => boolean)
const sortedSD = SortedArray.from([{ first: 3, second: 1 }], compareSD);
const sortedBuySell = SortedArray.from([buySell1, buySell2], compareBuySell);
```

Or Golang:

```go
// Custom comparison functions
func compareSD(a, b SD) bool {
    // some comparison here
}

func compareBuySell(a, b BuySell) bool {
    // some comparison here
}

// Constructors
sortedSD := NewSortedArrayWith([]SD{{1,2}, {3,1}}, compareSD)
sortedBuySell := NewSortedArrayWith([]BuySell{bs1, bs2}, compareBuySell)
```

Contrast this with Kotlin:

```kotlin
data class SD(val first: Int, val second: Int) : Comparable<SD> {
    override fun compareTo(other: SD) = {} // some custom compare method here
}

data class BuySell(val first: SD, val second: SD) : Comparable<BuySell> {
    override fun compareTo(other: BuySell) = {} // some custom compare method here
}

// Constructors
val sortedSD = SortedArray.from(listOf(SD(3,1), SD(1,2)))
val sortedBuySell = SortedArray.from(listOf(BuySell(sd1, sd2), BuySell(sd3, sd4)))
```

Or even the more verbose, Python, we override `__lt__`, `__eq__` and `__gt__` methods:

```python
@dataclass
class SD:
    first: int
    second: int

    def __lt__(self, other: 'SD') -> bool:
        # some custom comparison goes here

    def __eq__(self, other: 'SD') -> bool:
        # some custom equality check goes here

@total_ordering  # Generates other comparison methods from __lt__ and __eq__
@dataclass
class BuySell:
    first: SD
    second: SD

    def __lt__(self, other: 'BuySell') -> bool:
        # Custom: compare by sum of SD values
        self_sum = self.first.first + self.first.second + self.second.first + self.second.second
        other_sum = other.first.first + other.first.second + other.second.first + other.second.second
        return self_sum < other_sum

    def __eq__(self, other: 'BuySell') -> bool:
        return (self.first, self.second) == (other.first, other.second)


def main() -> None:
    sd_items: List[SD] = [SD(3, 1), SD(1, 2), SD(2, 1)]
    sorted_sd: SortedArray[SD] = SortedArray.from_list(sd_items)

    buysell_items: List[BuySell] = [
        BuySell(SD(1, 2), SD(3, 4)),  # sum = 10
        BuySell(SD(2, 1), SD(1, 1)),  # sum = 5
        BuySell(SD(5, 5), SD(5, 5))   # sum = 20
    ]
    sorted_buysell: SortedArray[BuySell] = SortedArray.from_list(buysell_items)
```

The beauty of the implicit way is that we can abstract away (from our working memory) how a list/array of custom data type is sorted (or how the elements are compared). And we don't need to pass it on every time we try to generate a sorted list of things.

Kotlin solves with the `Comparable<T>` type which mandates that you write a `compareTo` function. Haskell/Purescript solve this with the `Ord a` constraint which requires you to provide a `compare` function for your custom data types (if you need sorting, comparing functionality for those data types).

The difference between explicit and implicit is kind of stark if we think about it in layman terms. When we try to construct a `SortedArray`, the explicit ones are going, "Okay you asked me to sort a list of things, but can you also tell me how to compare the things?" every time we try to generate a sorted array. The implicit ones are going, "Okay you asked me to sort a list of _comparable_ things and somewhere in the codebase you've mentioned how to compare this specific thing so I will now construct the sorted array for you."

There is one pitfall though.

<div class="separator"></div>

###### What does it even mean to "compare" two things?

It is mostly straightforward if we think of numbers. Comparison is greater-than or less-than or equal-to. Booleans can be compared too if we assume True > False.

But what about strings? Should we compare them just lexically or should we also include the length in the comparison? Or what if, for a specific use-case, we only want to compare the length?

As an example, how to compare "apple" and "pear" depends on the context. Lexically, "apple" comes first. By length, "pear" comes first. Typically, we would do lexical followed by length — a useful but arbitrary convention.

Things get complex when we talk about product types. Product types are your objects or structs or dataclasses with multiple fields. These have multiple "dimensions" and what that means is there are many ways of comparing them. And each way could be valid and multiple comparing methods could be necessary.

Take my `StockDay`.

```hs
data StockDay = StockDay Price Day
type Price = Int
type Day = Int
```

This is basically a Tuple, but represented as data for type-level convenience.

What does comparing or sorting two `StockDay`s mean? In my limited use-case, it just means comparing on `Price`. But there could be a use-case where I want to sort them by `Day`.

The `Ord` instance will completely fail me in this case.

A naive, incomplete, pair-product-only solution would be:

```hs
class Sortable a where
  compareFst :: a -> a -> Ordering
  compareSnd :: a -> a -> Ordering
  compareBoth :: a -> a -> Ordering

instance sortableStockDay :: Sortable StockDay where
  compareFst (StockDay p1 _) (StockDay p2 _) =
    if p1 < p2 then LT else GT
  compareSnd (StockDay _ d1) (StockDay _ d2) =
    if d1 < d2 then LT else GT
  compareBoth s1 s2 =
    case compareFst s1 s2 of
      EQ -> compareSnd s1 s2
      ord -> ord
```

But there is no way for me to let the compiler or the runtime know dynamically which comparing function to use when I sort an array:

```hs
toSorted :: Array a -> SortedArray a
toSorted xs = SortedArray (Array.sort xs)
-- but notice how I cant tell the sort algo which sort to use
```

I would have to write a different function for each type of sort:

```hs
toSortedFst :: forall a. Sortable a => Array a -> SortedArray a
toSortedFst xs = SortedArray (Array.sortBy compareFst xs)

toSortedSnd :: forall a. Sortable a => Array a -> SortedArray a
toSortedSnd xs = SortedArray (Array.sortBy compareSnd xs)
```

And now notice how it's lost some guarantees again because I could end up using the `toSortedFst` where I should be using `toSortedSnd` and there would be nothing preventing me from doing that. The types would check.

Languages like OCaml and Rust have context-specific comparisons. So you could essentially have multiple ways to compare and when you try to sort, you can pass it an additional information that tells the compiler/runtime which comparison to use.

```ocaml
(* Define the interface *)
module type COMPARABLE = sig
  type t
  val compare : t -> t -> int
end

(* Different comparison strategies *)
module StringLexical : COMPARABLE with type t = string = struct
  type t = string
  let compare = String.compare
end

module StringByLength : COMPARABLE with type t = string = struct
  type t = string
  let compare s1 s2 = compare (String.length s1) (String.length s2)
end

module StringByLengthThenLexical : COMPARABLE with type t = string = struct
  type t = string
  let compare s1 s2 =
    let len_cmp = compare (String.length s1) (String.length s2) in
    if len_cmp = 0 then String.compare s1 s2 else len_cmp
end

(* Generic sort function *)
let sort (module Cmp : COMPARABLE) list =
  List.sort Cmp.compare list

(* Usage - explicit choice of comparison *)
let words = ["hello"; "hi"; "world"; "a"; "programming"]

let () =
  (* Sort lexicographically *)
  let lexical = sort (module StringLexical) words in
Printf.printf "Lexical: %s\n" (String.concat "; " lexical);
  (* Output: Lexical: a; hello; hi; programming; world *)

  (* Sort by length *)
  let by_length = sort (module StringByLength) words in
  Printf.printf "By length: %s\n" (String.concat "; " by_length);
  (* Output: By length: a; hi; hello; world; programming *)

  (* Sort by length then lexical *)
  let combined = sort (module StringByLengthThenLexical) words in
  Printf.printf "Length then lexical: %s\n" (String.concat "; " combined)
  (* Output: Length then lexical: a; hi; hello; world; programming *)

(* You can even parameterize functions by comparison strategy *)
let find_max (module Cmp : COMPARABLE) list =
  match list with
  | [] -> None
  | hd :: tl -> Some (List.fold_left (fun acc x ->
      if Cmp.compare x acc > 0 then x else acc) hd tl)

let () =
  let words = ["cat"; "elephant"; "a"; "dog"] in

  (* Max by lexical order *)
  (match find_max (module StringLexical) words with
   | Some max -> Printf.printf "Lexical max: %s\n" max  (* elephant *)
   | None -> ());

  (* Max by length *)
  (match find_max (module StringByLength) words with
   | Some max -> Printf.printf "Length max: %s\n" max   (* elephant *)
   | None -> ())
```

We're using the same "sort" keyword but we get to instruct the language to use a different algorithm using that `(module ....)` declaration. That is rad.

Arguably, these are edge-cases. It's not often that one needs multiple strategies to compare two things which then affects how one sorts their list. But the fact that language designers in Rust and OCaml thought of these cases as well — and generalised them enough — is quite fascinating.

<div class="separator"></div>

###### But it's just a wrapper! I shouldn't have to rewrite all methods

The `SortedArray` is merely a wrapper around `Array`. But because of the wrapping, any time I want to use an Array-like function (eg `head`, or `tail` or `!!` which is an operator to access the element at an index), I have to re-implement it. Like this:

```hs
head :: forall a. Ord a => SortedArray a -> Maybe a
head (SortedArray xs) = Array.head xs

filter :: forall a. Ord a => (a -> Boolean) -> SortedArray a -> SortedArray a
filter pred (SortedArray xs) = SortedArray (Array.filter pred xs)

-- and so on
```

You'd think that with all the advancements in compilers and type systems and type theory, this overhead wouldn't be required. After all, `SortedArray` is just a wrapper around a simple `Array`.

Of course, languages like Haskell/Purescript lets you _kind of_ get rid of this overhead.

To do this, we just do some "derive"s:

```hs
derive instance newtypeSortedArray :: Newtype (SortedArray a) _
derive newtype instance functorSortedArray :: Functor SortedArray
derive newtype instance foldableSortedArray :: Foldable SortedArray
derive newtype instance traversableSortedArray :: Traversable SortedArray
derive newtype instance applySortedArray :: Apply SortedArray
derive newtype instance applicativeSortedArray :: Applicative SortedArray
derive newtype instance bindSortedArray :: Bind SortedArray
derive newtype instance monadSortedArray :: Monad SortedArray
```

This gives us the ability to run operations like `map` and `fold` but for other array operations like `length`, we have to write our functions. Instead of doing unwrap/wrap over and over again, the `newtype` derivation allows us to simply use a generic function called `coerce` which does the unwrapping and wrapping for us:

```hs
import Data.NewType (coerce)

length :: SortedArray a -> Int
length = coerce Array.length
```

All this is great but there are downsides and flaws to this approach.

When we derive newtype instance for a type like `SortedArray`, the compiler makes the `SortedArray` constructor "exposed". That goes all the way back to my original problem with my old solution — exposing the constructor means I could construct a non-sorted-array and wrap it in `SortedArray` to make it look like it is sorted. But it won't be.

The other issue, specific to this use-case, is that deriving functions like `map` automatically does not keep the sorted-ness guarantee.

This is wrong (and depending on the usage, dangerous):

```hs
map :: (a -> b) -> SortedArray a -> SortedArray b
map = coerce Array.map

wrong = map (\x -> x * -1) (SortedArray [1,2,3,4])
-- wrong == SortedArray [-1,-2,-3,-4]

alsoWrong = map (\x -> if x > 4 then x * -1 else x) (SortedArray [1,2,3,6,7])
-- alsoWrong == SortedArray [1,2,3,-6,-7]
```

And there's nothing that informs me of that unless I peak into the mapping function.

The correct `map` goes like this:

```hs
map : forall a b. Ord a => Ord b => (a -> b) -> SortedArray a -> SortedArray b
map f xs = toSorted (Array.map f (fromSorted xs))
-- or more succinctly
-- map f = toSorted <<< Array.map f <<< fromSorted
```

There are a handful of other functions that would break sorting if `coerce`-d through newtype derivations. Like `mapWithIndex / indexedMap`, `insert`, `update`, `cons/snoc/push` etc. Anything that updates elements (in-place or as a new result) while retaining the array-like structure is a problem.

<div class="separator"></div>

I started this writeup as a journal entry after toying around with `SortedArray`'s compiler guarantees. But as I wrote, I began exploring around and ended up in various rabbit holes of parameterisation, polymorphism and typeclass-like behaviours of other languages.

Some wonderful abstractions here if you are mindful of the gotchas.
