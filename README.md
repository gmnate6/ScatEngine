# ScatEngine - v2.1.0

A deterministic, rules-complete Swift game engine for **Scat**, a multiplayer card game where players compete to build the best three-card hand of a single suit and race to 31.

ScatEngine is designed to be:

* Fully **state-driven**
* **Deterministic** (seeded RNG)
* UI-agnostic (no rendering logic)
* Safe via strong invariants and precondition checks
* Replayable via deterministic event streams and serialized game state

---

## Table of Contents

* Overview
* Game Summary
* Installation
* Quick Start
* Core API
* Game Flow
* Moves
* Scoring
* Encoding & Decoding
* Design Goals

---

## Overview

`ScatEngine` is the authoritative rules engine for the Scat card game. It manages:

* Turn order and player state
* Deck, draw pile, and discard pile
* Move validation and execution
* Round and game lifecycle
* Scoring and win conditions
* Knock resolution and Scat detection (31)

The engine emits a stream of `GameEvent`s for UI or networking layers to consume.

---

## Game Summary

Scat is played with 2–8 players using a standard 52-card deck.

Each player:

* Is dealt **3 cards**
* Takes turns drawing and discarding
* Tries to maximize a **single-suit hand score**
* Can optionally **knock** to trigger final turns

### Win Conditions

* Reach exactly **31 (Scat)** → immediate round win
* Otherwise, highest score after knock resolution wins

Players lose chips each round until only one remains.

---

## Installation

Add the engine as a Swift package dependency:

```swift
dependencies: [
    .package(url: "https://github.com/gmnate6/ScatEngine", from: "2.0.0")
]
```

---

## Quick Start

```swift
let engine = ScatEngine(
    seed: 42,
    playerCount: 4,
    startingChips: 3
)

let events = engine.startGame()

print(engine.currentPlayer.name)
print(engine.topOfDiscardPile)
```

### Playing a Move

```swift
let moves = engine.legalMoves()

if let move = moves.first {
    let events = try engine.makeMove(move)
    print(events)
}
```

---

## Core API

### Game State Access

After `startGame()` is called:

```swift
engine.players
engine.currentPlayer
engine.currentPlayerHand

engine.topOfDrawPile
engine.topOfDiscardPile

engine.drawPileSize
engine.discardPileSize

engine.alivePlayerIndices
```

---

### Game Status

```swift
engine.isStarted
engine.isActive
engine.isKnocked
engine.canKnock
engine.winnerIndex   // only valid when isActive == false
```

---

### Turn Info

```swift
engine.currentPlayerIndex
engine.moveNumber
engine.roundNumber
```

---

## Game Flow

1. Initialize engine with seed + players
2. Call `startGame()`
3. Loop:

   * Query `legalMoves()`
   * Call `makeMove(_:)`
   * Process `GameEvent`s
4. Repeat until only one player remains

### Knock Phase Behavior

When a player knocks:

* All remaining players receive one final turn
* The knock initiator does NOT immediately win
* The round ends after turn order returns to the knocking player

---

## Moves

The engine supports two move types:

### Draw + Discard

```swift
.drawAndDiscard(source: DrawSource, discard: Card)
```

Draw from:

* `.drawPile`
* `.discardPile`

Then discard exactly one card.

#### Reshuffle Rule

If the draw pile becomes empty after drawing:

* The discard pile is immediately reshuffled into a new draw pile
* Then play continues normally

---

### Knock

```swift
.knock
```

Triggers final round phase:

* Remaining players get one final turn each
* After turn order returns to the knocker, resolution begins

---

## Scoring

Only the highest single-suit sum counts.

Card values:

* Ace = 11
* Face cards = 10
* Number cards = face value

```swift
Scoring.score(of: player)
Scoring.isScat(player: player) // 31
```

---

## Scat (31)

* Immediate round win
* Overrides any active knock
* Ends the round instantly even if knock was already triggered

---

## Encoding & Decoding

### Encode Game State

```swift
let data = try ScatEngineSerializer.encode(engine)
```

### Restore Game

```swift
let engine = try ScatEngineSerializer.decode(data)
```

### State Hash

```swift
let hash = ScatEngineSerializer.hash(engine)
```

Used for:

* Multiplayer sync validation
* Replay debugging
* Determinism verification

---

## Design Goals

### 1. Deterministic Simulation

Same seed + moves → identical outcomes.

### 2. Strict State Safety

Invalid operations fail fast via preconditions or thrown errors.

### 3. Event-Driven Output

All meaningful actions emit `GameEvent`s:

* draws
* discards
* knock
* reshuffles
* round end

### 4. UI Separation

No rendering logic exists in the engine.

### 5. Replayability

Games can be fully reconstructed from:

* seed + moves
* serialized state

---

## Key Invariants

* Each active player always has exactly 3 cards (engine-maintained invariant)
* Only top discard is visible/drawable
* Eliminated players remain in turn order but are skipped
* A round ends via:

  * Knock resolution
  * Scat (31)
* Game ends when only one player has chips

---

## Notes on API Safety

* `winnerIndex` is only valid when `isActive == false`
* `legalMoves()` is only valid during an active game
* Knock state is included in `legalMoves()` constraints via `MoveRules`
* Reshuffling occurs immediately after a draw if the draw pile becomes empty

---

## License

MIT
