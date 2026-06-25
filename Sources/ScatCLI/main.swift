// ============================================================
// main.swift  –  ScatCLI
// ============================================================

import Foundation
import ScatEngine

// ── Configuration ───────────────────────────────────────────
let useFixedSeed: Bool = false
let doesClear:    Bool = false
// ── Helpers: terminal ───────────────────────────────────────

func clearScreen() {
    guard doesClear else { return }
    print("\u{1B}[2J\u{1B}[H", terminator: "")
}

func waitForEnter(prompt: String = "Press Enter to continue…") {
    print("\n\(prompt)", terminator: " ")
    _ = readLine()
}

/// Reads a line and returns an Int, or nil if invalid.
func readInt() -> Int? {
    guard let line = readLine()?.trimmingCharacters(in: .whitespaces) else { return nil }
    return Int(line)
}

/// Keeps prompting until the user enters a valid index from the menu.
func readChoice(from options: [(key: String, label: String)]) -> String {
    while true {
        for opt in options {
            print("  \(opt.key)) \(opt.label)")
        }
        print("> ", terminator: "")
        let raw = readLine()?.trimmingCharacters(in: .whitespaces) ?? ""
        if options.contains(where: { $0.key == raw }) { return raw }
        print("Invalid choice. Try again.")
    }
}

/// Keeps prompting until the user enters an integer in [lo, hi].
func readIntInRange(lo: Int, hi: Int, prompt: String) -> Int {
    while true {
        print(prompt, terminator: " ")
        if let n = readInt(), n >= lo && n <= hi { return n }
        print("Please enter a number between \(lo) and \(hi).")
    }
}

// ── Helpers: formatting ─────────────────────────────────────

func suitSymbol(_ suit: Suit) -> String {
    switch suit {
    case .clubs:    return "♣"
    case .diamonds: return "♦"
    case .hearts:   return "♥"
    case .spades:   return "♠"
    }
}

func rankString(_ rank: Rank) -> String {
    switch rank {
    case .two:   return "2"
    case .three: return "3"
    case .four:  return "4"
    case .five:  return "5"
    case .six:   return "6"
    case .seven: return "7"
    case .eight: return "8"
    case .nine:  return "9"
    case .ten:   return "10"
    case .jack:  return "J"
    case .queen: return "Q"
    case .king:  return "K"
    case .ace:   return "A"
    }
}

func cardString(_ card: Card) -> String {
    "\(rankString(card.rank))\(suitSymbol(card.suit))"
}

func chipString(_ n: Int) -> String {
    n > 0 ? String(repeating: "●", count: n) : "✗ (eliminated)"
}

// ── Helpers: display ────────────────────────────────────────

let boxWidth = 52

func boxLine(_ text: String = "") -> String {
    if text.isEmpty { return "│" + String(repeating: " ", count: boxWidth) + "│" }
    let padded = " \(text) "
    let right  = max(0, boxWidth - padded.count)
    return "│\(padded)\(String(repeating: " ", count: right))│"
}

func boxDivider() -> String { "├" + String(repeating: "─", count: boxWidth) + "┤" }
func boxTop()     -> String { "┌" + String(repeating: "─", count: boxWidth) + "┐" }
func boxBottom()  -> String { "└" + String(repeating: "─", count: boxWidth) + "┘" }

func banner(_ text: String, char: Character = "═") {
    let line = String(repeating: char, count: boxWidth + 2)
    print(line)
    let pad  = max(0, boxWidth + 2 - text.count) / 2
    print(String(repeating: " ", count: pad) + text)
    print(line)
}

func printTurnDisplay(engine: ScatEngine) {
    let player = engine.currentPlayer
    let score  = Scoring.score(of: player)
    let hand   = player.cards

    print(boxTop())
    print(boxLine("PLAYER: \(player.name)"))
    print(boxLine("Chips : \(chipString(player.chips))   Score: \(score)"))
    print(boxDivider())
    print(boxLine("Draw pile: \(engine.drawPileCount) cards   Discard top: \(cardString(engine.topDiscard))"))
    print(boxDivider())
    print(boxLine("Hand:"))
    for (i, card) in hand.enumerated() {
        print(boxLine("  \(i + 1). \(cardString(card))  (\(Scoring.value(of: card)) pts)"))
    }
    print(boxBottom())
}

func printFinalRoundBanner() {
    print("")
    banner("⚑  FINAL ROUND  ⚑", char: "═")
    print("")
}

func printRoundSummary(engine: ScatEngine, before: [Player]) {
    // `before` is the snapshot of players prior to resolveKnock mutating chips.
    // We compare chips to find who lost one.
    let after  = engine.players
    let active = engine.activePlayers

    print("")
    banner("── ROUND OVER ──", char: "─")

    // Scores
    print("\nFinal scores:")
    for p in before {
        let score = Scoring.score(of: p)
        print("  \(p.name.padding(toLength: 10, withPad: " ", startingAt: 0))  \(score) pts")
    }

    // Who lost chips
    print("\nResults:")
    for (old, new) in zip(before, after) {
        if new.chips < old.chips {
            print("  \(old.name) lost a chip  (\(old.chips) → \(new.chips))")
        }
        if !new.isAlive {
            print("  \(old.name) has been eliminated!")
        }
    }

    // Scoreboard
    print("\nScoreboard:")
    for p in after {
        let status = p.isAlive ? chipString(p.chips) : "ELIMINATED"
        print("  \(p.name.padding(toLength: 10, withPad: " ", startingAt: 0))  \(status)")
    }

    // Remaining active players
    print("\nStill in the game: \(active.map(\.name).joined(separator: ", "))")
    print("")
    waitForEnter()
}

func printGameOver(engine: ScatEngine) {
    clearScreen()
    banner("★  GAME OVER  ★")
    print("")
    if let winner = engine.winner {
        print("  🏆  Winner: \(winner.name)  🏆")
    }
    print("\nFinal chip counts:")
    for p in engine.players {
        print("  \(p.name.padding(toLength: 10, withPad: " ", startingAt: 0))  \(chipString(p.chips))")
    }
    print("")
}

// ── Round-end detection ─────────────────────────────────────
// We detect a round boundary by comparing the round state before and after
// applying a move. If the current player index resets back to the first
// alive player AND chips changed (or game over), a new round started.

func snapshotPlayers(_ engine: ScatEngine) -> [Player] {
    engine.players
}

func roundEnded(before: [Player], after: [Player]) -> Bool {
    // A round ended when at least one player's chip count changed.
    for (a, b) in zip(before, after) {
        if a.chips != b.chips { return true }
    }
    return false
}

// ── Entry point ─────────────────────────────────────────────

let seed: UInt64 = useFixedSeed ? 42 : UInt64.random(in: .min ... .max)

var engine = ScatEngine(
    seed: seed,
    players: ["Nathan", "Chloe", "Carla", "Colby"],
    startingChips: 3
)

// Track whether we already printed a knock banner this round
var knockBannerShown = false

while engine.isActive {
    clearScreen()

    // Final-round banner
    if engine.isKnocked && !knockBannerShown {
        printFinalRoundBanner()
        knockBannerShown = true
    }

    printTurnDisplay(engine: engine)
    print("")

    // Snapshot before the move
    let beforePlayers = snapshotPlayers(engine)

    // ── Main menu ────────────────────────────────────────────
    print("What would you like to do?")
    var menuOptions: [(key: String, label: String)] = [("1", "Draw a card")]
    if !engine.isKnocked {
        menuOptions.append(("2", "Knock"))
    }
    let mainChoice = readChoice(from: menuOptions)

    if mainChoice == "2" {
        // Knock
        let move = Move(playerID: engine.currentPlayer.id, action: .knock)
        do {
            try engine.apply(move)
        } catch {
            print("Error: \(error). Press Enter.")
            _ = readLine()
        }
    } else {
        // Draw flow
        print("")
        print("Draw from:")
        let drawChoice = readChoice(from: [
            ("1", "Draw pile"),
            ("2", "Discard pile  [\(cardString(engine.topDiscard))]")
        ])
        let source: DrawSource = drawChoice == "1" ? .drawPile : .discardPile

        // Peek at what they're about to draw
        let drawnCard: Card = source == .drawPile ? engine.topDraw : engine.topDiscard

        // Show drawn card
        print("")
        print("You drew: \(cardString(drawnCard))")

        // Build temporary hand for display (engine hasn't applied move yet,
        // so we simulate it for the prompt)
        let currentHand = engine.currentPlayer.cards
        let tempHand    = currentHand + [drawnCard]

        print("\nYour four-card hand:")
        for (i, card) in tempHand.enumerated() {
            print("  \(i + 1). \(cardString(card))  (\(Scoring.value(of: card)) pts)")
        }
        print("")

        let discardIdx = readIntInRange(lo: 1, hi: tempHand.count,
                                        prompt: "Which card would you like to discard? (1–\(tempHand.count)):")
        let discardCard = tempHand[discardIdx - 1]

        let move = Move(
            playerID: engine.currentPlayer.id,
            action: .drawAndDiscard(source: source, discard: discardCard)
        )
        do {
            try engine.apply(move)
        } catch {
            print("Error: \(error). Press Enter.")
            _ = readLine()
        }
    }

    // ── Detect round end ─────────────────────────────────────
    let afterPlayers = snapshotPlayers(engine)
    if roundEnded(before: beforePlayers, after: afterPlayers) {
        knockBannerShown = false
        clearScreen()
        printRoundSummary(engine: engine, before: beforePlayers)
    }
}

printGameOver(engine: engine)
