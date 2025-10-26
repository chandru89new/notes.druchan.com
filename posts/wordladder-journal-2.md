---
title: Wordladder Journal Ep. 2
date: 2025-10-02
slug: wordladder-journal-2
status: published
---

- I decided to try building the game as a CLI/terminal app before shifting to the frontend/Elm parts of it. So I spent time writing out the game loop essentially.
- I modeled the game state first:

```haskell
type GameState =
  { gameStatus :: GameStatus
  , dictionary :: Set String
  , gameWords :: Tuple String String
  , lastPlayedWord :: String
  , gameType :: GameType
  , playedWords :: Array String
  }

data GameType = PvC | PvP

data GameStatus = Play Player | Win Player | Over String
data Player = User | Computer
```

- I might eventually make this a two-person game besides playing against the computer, hence the `GameType` datatype.
- The game loop itself was just a function that looked at the game "status" (`GameState.gameStatus`) and ran a bunch of functions. It would end up looping over itself (recursion) or end the game. Example, if the `gameStatus` was `Play User`, then the game would ask for user input, and then process the user input and decide on the next `gameStatus`.
- This ended up being a little tedious but gave a nice-little self-contained game loop.
- Along the way, I wrote some helper functions to colorise the log outputs.
- The game loop itself was an effectful-function:

```haskell
gameLoop :: GameState -> Aff GameState
```

- The game works in its present shape but I am not too happy about the complexities of mixing effectful functions like asking for user-input, logging to console etc. into the core "update the state of the game based on previous state" idea. I'll have to explore how to achieve that separation.
- There is a part of the logic where I compute all possible playable words (so that if it's the computer's turn, it can play a word). I devised a way to sort/compare, by using the `hamming` distance. Example: if the target word is `test`, and there's a list of possible words that _could_ lead there in one or more steps, like `[bees, fees, tent, poke]`, it figures out that `tent` is actually much closer to `test` than others. It does this by comparing each character of both the words `(test, tent)`, scoring a 0 if both are same and a 1 if both are different, so `(0,0,1,0)`, and then summing it up `(1)`. In the case of `(bees, test)`, it will be `(1,0,1,1)` so the sum is `(3)`.

```haskell
rankByClosest :: String -> Array String -> Array String
rankByClosest target wrds = sortBy (comparing (hammingDistance target)) wrds

hammingDistance :: String -> String -> Int
hammingDistance wrd1 wrd2 =
  let
    chars1 = split (Pattern "") wrd1
    chars2 = split (Pattern "") wrd2
    differences = zipWith (\c1 c2 -> if c1 == c2 then 0 else 1) chars1 chars2
  in
    sum differences
```

- The game runs thus:

![](/images/wordladder.png)
