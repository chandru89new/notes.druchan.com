---
title: Wordladder Journal
date: 2025-10-05
slug: wordladder-journal-1
status: published
collections: Project journal, Functional programming
---

- [Episode 1](#episode-1) - _Oct 01, 2025_
- [Episode 2](#episode-2) - _Oct 02, 2025_
- [Episode 3](#episode-3) - _Oct 03, 2025_
- [Episode 4](#episode-4) - _Oct 04, 2025_

###### Episode 1

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

###### Episode 2

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

###### Episode 3

- Today, I added a bundling script so that the common JS output from the Purescript files can be run like a (node) executable. With some basic esbuild configuration and this line: `spago build && node bundle.js && chmod +x ./dist/word-ladder`, the final executable can be just run directly in a node shell.
- Following from [Ep 2](#episode-2), where I wanted to separate out the effectful parts of the game loop from the pure computation, I started ideating some simple options with Claude. A simple mental model emerged: the game consists of two things. One, the game's state and two, the game's side-effects. Iterating over this idea, I ended up sort of reinventing Elm's architecture pattern (also called `TEA` for "The Elm Architecture"). The idea is that there are two primitives representing an app: a global state and a bunch of effects. A handler at the top-level runs the effects and returns a new state, which is then fed back into a game-state-updater function.

```haskell
type GameState = { ... }
data GameEffect = Effect1 | Effect2 | ...

updateGame :: GameState -> Tuple GameState (Array GameEffect)

handleEffect :: GameState -> GameEffect -> Aff (Tuple GameState (Array GameEffect))
handleEffects :: GameState -> Array GameEffect -> Aff GameState
handleEffects = -- some fold function that reduces Array GameEffect into a GameState with side-effects run correctly

gameLoop :: GameState -> Aff Unit
gameLoop gameState = do
	let (Tuple newState effects) = updateGame gameState
	finalState <- handleEffects newState effects
	gameLoop finalState
```

- The easiest part was to write the `handleEffects` handler which took some state of the game, a bunch of effects to run, ran those effects and fed the new state and effects to the next effect in the list and finally produced a new, ultimate game state.

```haskell
handleEffects :: GameState -> Array GameEffect -> Aff GameState
handleEffects state effects = go effects state
  where
  go :: Array GameEffect -> GameState -> Aff GameState
  go effs s = case A.head effs of
    Nothing -> pure $ s
    Just e -> do
      Tuple s' newEffs <- handleEffect s e
      go (newEffs <> (fromMaybe [] $ A.tail effs)) s'
```

- The trickiest part was getting the model right — that running an effect produces not just a new game state but could also produce a list of new effects (more side-effects!).
- Example, one of the `GameEffect`s is the effect to "ask user to choose difficulty (3,4,5-letter words)":

```haskell
data GameEffect
  = Log String
  | Exit Int
  | AskUserToChooseDifficulty -- <- this one
  -- | others
```

- If the game runs this effect, it will ask the user to input a number between 3 and 5. What if the user entered an invalid input? It will return the same effect because the game should once again ask for user input:

```haskell
handleEffect :: GameState -> GameEffect -> Aff (Tuple GameState (Array GameEffect))
handleEffect state AskUserToChooseDifficulty = do
  input <- readLine $ colorInfo "Choose word length (3, 4, or 5)"
  if (elem input [ "3", "4", "5" ]) then
    pure $ Tuple (state { currentState = DifficultySet (fromMaybe 3 (fromString input)) }) []
  else do
    log $ colorError "Invalid input. Please enter 3, 4, or 5."
    pure $ Tuple state [ AskUserToChooseDifficulty ]
```

- The biggest benefit of this mechanism (separating game-state update function and effects), is that now I have this neat, pure function that I can test in an idempotent way. No side-effects, no mocks. Just straight up test and check with equality.

```haskell
updateGameState :: GameState -> Tuple GameState (Array GameEffect)
```

- I also decided to bundle and publish this as an `npm` package that you could just run as `npx`. I did something that didnt quite work and ended up hastily deleting the package from `npm`. Then, found out I couldnt push the package with the same name again for another 24 hours.

**Update:**

- The game is now playable in your terminal if you just ran [`npx wordladder`](https://www.npmjs.com/package/wordladder).

###### Episode 4

- I had a really long experiment session with Claude today to see if there were other abstractions and functional programming ideas that I could tap into, to make my game model succinct. Many ideas floated around — MTL (monad-transformers), effect libraries, Free monad etc. I picked the Free monad path and tried to reason about the program.
- Free monad is a recursive data structure that appears to be used in situations where we want to "continue" doing some effects after computing something. These are typically called continuations, and there is a specific style of programming called "continuation passing style" and the Free monad, a data structure, can capture that idea in a type-safe way. A free monad looks like this:

```haskell
data Free f a = Pure a | Free (f (Free f a))
```

- Wrapping or using this for my `GameEffect`, and building a structure here quickly became quite complex. And besides, when trying to understand or see how this could play out when running one effect spans more effects, it felt almost impossible to do that without adding more complexities.
- I went back to the drawing board, ideated some more with Claude, and kept hammering the notion that I wanted a really simple, grokkable (by my standards) version and it kept giving up, telling me what I had was just fine. Then, out of the blue, it remembered that I could use the `Writer` monad. That monad is usually used when logging is done as part of running functions, but the key idea is that the monad allows "accumulation" of some data (that can be accumulated or concatenated — so, things like lists and strings). In my case, I am accumulating a list of game effects `(Array GameEffect)`, so I could just as well use the `Writer` monad. And I did that.

```haskell
updateGameState :: GameState -> Writer (Array GameEffect) GameState
updateGameState state = case state.currentState of
  NotInitialized -> do
    tell [ AskUserToChooseDifficulty ]
    pure state

  DifficultySet int -> do
    tell [ InitializeGame ]
    pure (state { dictionary = dict, wordLength = int })
    where
    dict = getAllWordsByLen int

  -- and more
```

- The main game loop then "runs" the writer, collects the effects, runs them and keeps looping until game exits.

```haskell
loop state = do
        let Tuple newState effects = runWriter (updateGameState state)
        finalState <- handleEffects newState effects
        loop finalState
    loop initialState

-- where runWriter is:
runWriter :: Writer w a -> Tuple a w
-- where
-- w is Array GameEffect
-- a is GameState
```

- Even though this is not an idiomatic way of using the `Writer` monad, it fits the purpose neatly.

**Update**

- I happened to read up some more around recursing over in effectful functions. The `handleEffects` function was doing some recursion till effects was empty and turns out I could use something called a `tailRecM` for reasonably stack-safe recursion in an effectful context. So I swapped it after a bit of tinkering around with this:

```haskell
handleEffects :: GameState -> Array GameEffect -> Aff GameState
handleEffects initialState initialEffects =
  tailRecM go (Tuple initialState initialEffects)
  where
  go :: (Tuple GameState (Array GameEffect)) -> Aff (Step (Tuple GameState (Array GameEffect)) GameState)
  go (Tuple state effects) = case A.uncons effects of
    Nothing -> pure $ Done state
    Just { head: eff, tail: rest } -> do
      Tuple state' newEffects <- handleEffect state eff
      pure $ Loop (Tuple state' (newEffects <> rest))

data Step a b = Done b | Loop a
```
