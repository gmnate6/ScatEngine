# Scat Rules

## Overview

Scat is a multiplayer card game where players compete to build the highest-valued three-card hand of a single suit. The game is played over multiple rounds until only one player has chips remaining.

---

# Objective

## Round Objective

Win each round by having the highest-valued hand when the round ends.

A round ends when:

* A player knocks.
* A player achieves **Scat (31)**.

## Game Objective

Remain the last player with at least one chip.

---

# Players

* Minimum players: 2
* Maximum players: 8

Players who lose all chips are eliminated and do not participate in future rounds.

---

# Components

* One standard 52-card deck
* No Jokers (base game)
* Chips (host chooses starting amount; 3 is the traditional default)

---

# Card Values

| Card         |      Value |
| ------------ | ---------: |
| Ace          |         11 |
| King         |         10 |
| Queen        |         10 |
| Jack         |         10 |
| Number Cards | Face Value |

Only **one suit** is scored.

Example:

* A♥ + 9♥ + 4♣ = **20**
* K♠ + Q♠ + J♠ = **30**

There is **no special value** for three-of-a-kind.

Maximum score is **31**.

---

# Setup

At the beginning of every round:

1. Shuffle the deck.
2. Deal three cards to every active player.
3. Flip one card face-up to begin the discard pile.
4. Place the remaining cards face-down as the draw pile.
5. Determine the starting player.

Players always begin a round with exactly three cards.

---

# Turn Structure

Each player's turn consists of:

1. Draw one card.
2. Discard one card.

Players may draw from either:

* The top of the draw pile.
* The top card of the discard pile.

Only the **top discard card** may be taken.

After drawing, the player must discard one card.

A player's hand always contains exactly three cards at the end of their turn.

---

# Knocking

Instead of drawing, a player may choose to **Knock**.

Knocking immediately begins the final round.

After a knock:

* Every other active player receives exactly one final turn.
* The knocker does **not** receive another turn.
* Scores are revealed after the final player finishes.

Knocking is a risk.

The knocker is effectively betting that their score is higher than at least one other active player.

If the knocker does **not** have a higher score than any other active player (every other player is tied with or higher than the knocker), the knocker loses **two chips** instead of one.

---

# Scat (31)

A player who reaches exactly **31** immediately wins the round.

This ends the round instantly.

No additional turns are played.

If a player reaches 31 during the final turns after a knock, the Scat immediately overrides the knock outcome.

---

# Round Resolution

## Normal Knock

After the final turns:

* The player(s) with the lowest score each lose one chip.

If multiple players tie for the lowest score:

* Every tied player loses one chip.

## Failed Knock

If the knocker fails to beat at least one other active player:

* The knocker loses two chips.

No other player loses chips.

## Scat

If a player achieves 31:

* Every other active player loses one chip.
* The player with Scat loses no chips.

If Scat occurs during the final turns following a knock:

* Every active player except the player with Scat loses one chip.
* The knocker loses only one chip (not the failed-knock penalty of two).

---

# Eliminated Players

A player who loses their final chip is eliminated.

Eliminated players:

* Do not receive cards.
* Do not take turns.
* Cannot win future rounds.

The game continues until only one active player remains.

That player wins the game.

---

# Draw Pile Exhaustion

If a player draws the last card from the draw pile:

1. Shuffle all discard pile cards into a new draw pile.
2. The player then discards as normal, ending their turn with one card in the discard pile.

The discard pile is empty between the draw and the discard, but is always replenished by the end of the turn.

---

# Public Information

The following information is visible to every player:

* Number of chips each player has
* Turn order
* Current player
* Top discard card
* Which pile a player drew from
* Which card a player discarded

If a player draws from the discard pile, the drawn card is public knowledge because it was already visible.

---

# Private Information

The following information is private:

* A player's hand
* Cards drawn from the draw pile

No other information is hidden.

---

# Optional Joker Rules (Future Feature)

Jokers are **not part of the base game** and are disabled by default.

When enabled, the previous game's winner selects the Joker mode before the next game begins.

The exact Joker behavior depends on the selected mode.

Example modes include:

* Skip the next player's turn.
* Reverse turn order.
* Wild card worth any value.
* Forced Knock.
* Other house rules.

Common Joker rules:

* Jokers are never dealt during setup.
* Jokers may only be obtained from the draw pile.
* Jokers may never be discarded.
* After a Joker is used, it is removed from the game for the remainder of the round.

The exact behavior of Jokers is determined by the selected game mode.

---

# Implementation Invariants

The following rules should always be true during gameplay.

## Players

* Seat order is fixed for the duration of the game.
* Eliminated players remain in the player list.
* Eliminated players are skipped when determining turn order.
* Only active players receive cards.

## Hands

* Every active player has exactly three cards at the end of every turn.
* Hands are private.
* Cards drawn from the draw pile are private.
* Cards taken from the discard pile are public.

## Discard Pile

* The discard pile is never empty.
* Only the top discard card may be drawn.
* The top discard card is always public.

## Chips

* Chip counts are public information.
* Players with zero chips are eliminated immediately after the round ends.

## Rounds

A round always ends by exactly one of:

* Knock
* Scat (31)

A new round cannot begin until the previous round has been completely resolved.

## Turns

Every completed turn consists of:

1. Draw exactly one card.
2. Discard exactly one card.

Unless the player immediately achieves Scat.

## Networking

All clients must agree on:

* Player order
* Active players
* Current turn
* Chip counts
* Discard pile
* Draw pile size
* Game settings

Only private hands and unseen draw-pile cards are hidden from other players.

## Animation

Animations are presentation only.

Animations must never change game state.

The game engine should always compute the resulting state first, after which the UI replays the move through animations.
