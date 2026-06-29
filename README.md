# ScatEngine

A deterministic, rules-complete Swift game engine for **Scat**, a multiplayer card game where players compete to build the best three-card hand of a single suit and race to 31.

ScatEngine is designed to be:
- Fully **state-driven**
- **Deterministic** (seeded RNG)
- UI-agnostic (no rendering logic)
- Safe via strong invariants and precondition checks
- Replayable via event streams and save files

---

## Table of Contents

- [Overview](#overview)
- [Game Summary](#game-summary)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Core API](#core-api)
- [Game Flow](#game-flow)
- [Moves](#moves)
- [Scoring](#scoring)
- [Saving & Loading](#saving--loading)
- [Design Goals](#design-goals)

---

## Overview

`ScatEngine` is the authoritative rules engine for the Scat card game. It manages:

- Turn order and player state
- Deck, draw pile, and discard pile
- Move validation and execution
- Round and game lifecycle
- Scoring and win conditions
- Knock resolution and Scat detection (31)

The engine emits a stream of `GameEvent`s for UI or networking layers to consume.

---

## Game Summary

Scat is played with 2–8 players using a standard 52-card deck.

Each player:
- Is dealt **3 cards**
- Takes turns drawing and discarding
- Tries to maximize a **single-suit hand score**
- Can optionally **knock** to trigger final turns

### Win Conditions
- Reach exactly **31 (Scat)** → immediate round win
- Otherwise, highest score after knock resolution wins

Players lose chips each round until only one remains.

---

## Installation

Add the engine as a Swift package dependency (example):

```swift
dependencies: [
    .package(url: "https://github.com/your-repo/ScatEngine", from: "1.0.0")
]
````

---

## Quick Start

```swift
let engine = ScatEngine(
    seed: 42,
    players: ["Alice", "Bob", "Charlie"],
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
engine.drawPileSize
engine.discardPileSize
engine.topOfDiscardPile
```

### Game Status

```swift
engine.isStarted
engine.isActive
engine.isKnocked
engine.canKnock
```

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
4. Repeat until game ends (one player remains)

---

## Moves

The engine supports two move types:

### Draw + Discard

```swift
.drawAndDiscard(source: DrawSource, discard: Card)
```

* Draw from:

  * `.drawPile`
  * `.discardPile`
* Must discard exactly one card

### Knock

```swift
.knock
```

Triggers final round:

* All other players get one final turn
* Then scoring is resolved

---

## Scoring

Only the highest single-suit sum counts.

Card values:

* Ace = 11
* Face cards = 10
* Number cards = face value

```swift
Scoring.score(of: player)
Scoring.isScat(player: player) // == 31
```

### Scat (31)

* Instant round win
* Overrides knock resolution
* Other players lose chips

---

## Saving & Loading

### Encode Game State

```swift
let data = try engine.encode()
```

### Restore Game

```swift
let engine = try ScatEngine(data: savedData)
```

### State Hash (Integrity Check)

```swift
let hash = try engine.stateHash()
```

Used for:

* Sync validation
* Multiplayer reconciliation
* Debugging desyncs

---

## Design Goals

### 1. Deterministic Simulation

Given the same seed and moves, the engine always produces identical results.

### 2. Strict State Safety

Invalid operations crash early via `precondition` or throw errors.

### 3. Event-Driven Output

All meaningful actions emit `GameEvent`s:

* draws
* discards
* knock
* reshuffles
* round end

### 4. UI Separation

The engine contains **no UI logic**—only rules and state transitions.

### 5. Replayability

Every game can be replayed from:

* seed + moves
* or full encoded state

---

## Key Invariants

* Each active player always has **exactly 3 cards**
* Only top discard is visible and drawable
* Eliminated players remain in turn order but are skipped
* A round always ends in either:

  * Knock resolution
  * Scat (31)
* Game ends when only one player has chips

---

## License

MIT
