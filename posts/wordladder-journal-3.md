---
title: Wordladder Journal Ep. 3
date: 2025-10-03
slug: wordladder-journal-3
status: published
---

- Today, I added a bundling script so that the common JS output from the Purescript files can be run like a (node) executable. With some basic esbuild configuration and this line: `spago build && node bundle.js && chmod +x ./dist/word-ladder`, the final executable can be just run directly in a node shell.
- Following from [Ep 2](./wordladder-journal-2), where I wanted to separate out the effectful parts of the game loop from the pure computation, I started ideating some simple options with Claude. A simple mental model emerged: the game consists of two things. One, the game's state and two, the game's side-effects. Iterating over this idea, I ended up sort of reinventing Elm's architecture pattern (also called `TEA` for "The Elm Architecture"). The idea is that there are two primitives representing an app: a global state and a bunch of effects. A handler at the top-level runs the effects and returns a new state, which is then fed back into a game-state-updater function.

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
