---
title: Wordladder Journal Ep. 1
date: 2025-10-01
slug: wordladder-journal-1
status: published
---

- I've been thinking of writing some small toy-programs / games. Preferably in Elm if it's just UI, and Purescript if it involves some backend. Honed in on something to do with "levenshtein distance" so, basically, a [word-ladder game](https://en.wikipedia.org/wiki/Word_ladder).
- In prepping for this, I thought I could write the base logic in Purescript first to test out the idea. So day 1 was just about doing that.
- I thought of the game play like this: two 4-letter words are picked at random by the game (the source word and the target word). You play a turn, and then the computer plays a turn and so on till you or the computer reach the target word. Example: the game picks "ball" and "test". On your turn, you play a word and the program checks if the word you played is allowed — that is, it has to be just one-letter different from "ball". (eg "bull", "bale", "tall", "fall" etc.). Then the computer plays and so on.
- The most critical piece of this seemed to be picking two words that are actually "playable"... that is, pick two words such that one can reach the target word from the source word. I knew, from old Advent of Code puzzles, that this called for some kind of a tree-search. Which, in functional languages, means recursion.
- The way I thought about it was to think about "paths". Example: `[ball]` is the starting point. Now, consider all possibilities: `[ball,tall]` is a possibility. `[ball,bull]` is another. That means, I can start with a word, and have many potential paths.

```
[ball] -> [[ball,tall],[ball,bull],[ball,fall]...]`
```

- Next, I pick the first path (`[ball,tall]`), and figure out next potential words in that path, and construct a new list of paths.

```
[ball,tall] -> [ball,tall,fall], [ball,tall,till], [ball,tall,tale], ...and so on
```

- I would add these new paths to the recursion queue and just keep going. The base/ending would be if I found the target word in any of the paths that I generate. Or if I run out of the queue.
- Armed with this idea, I started carving out the function so:

```haskell
walk :: Set String -> String -> Array (Array String) -> Set String -> Maybe (Array String)
walk dictionary target queue visited = ??
```

- `dictionary` was all valid English words (to pick the next potential valid word in a path) and `visited` is a list of words that have already been added to some path so that duplicates and already-visited paths are excluded.
- Actually, in the first iteration, I missed the `visited` one and ended up with infinite recursion (but tail-call optimized, and perhaps that's why it just hung instead of blowing the JS heap). Claude-ing the issue surfaced the problem and then things were fine.
- In writing the `walk` function, I had to also write another function to get "potential next words". Example: given "ball", what are all the possible next words? This one was interesting because I could tap into the list comprehension mechanics of Purescript/Haskell:

```haskell
getAllPossibilities :: Set String -> String -> Array String
getAllPossibilities dictionary wrd =
  let
    alphabets = split (Pattern "") "abcdefghijklmnopqrstuvwxyz"
    wrdAsArray = split (Pattern "") wrd
    indices = 0 .. (length wrd - 1)
    possibilities = do
      idx <- indices
      c <- alphabets
      let newWord = mapWithIndex (\i ch -> if i == idx then c else ch) wrdAsArray
      guard (isValidWord dictionary (joinWith "" newWord) && (joinWith "" newWord) /= wrd)
      pure (joinWith "" newWord)
  in
    possibilities
```

- It just creates two arrays: one, a list of all alphabets, and second, a list of indices in the given word. Then, it does a permutation. Everything inside the `do` block can be thought of as a `for` loop in this case. There are two `for` loops here: one that increments through the `indices` and another (the internal) that increments/iterates through the `alphabets`.
- Once these two fundamental blocks were there, I could also write another function using these to get the shortest path.

```haskell
getShortestPath :: Set String -> String -> String -> Maybe (Tuple Int (Array String))
getShortestPath dictionary source target =
  if length source /= length target then
    Nothing
  else
    let
      res = walk dictionary target [ [ source ] ] (Set.singleton source)
    in
      map (\path -> Tuple (A.length path - 1) path) res
```

- On second thoughts, maybe I could just return `Maybe (Array String)` instead of a Tuple.
- I ended the day with this. The gameplay mechanics will need to be figured out but it might be best to do it in Elm and transfer these functions there.
