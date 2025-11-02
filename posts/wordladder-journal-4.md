---
title: Wordladder Journal Ep. 4
date: 2025-10-05
slug: wordladder-journal-4
status: published
---

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
