// ============================================================
// main.swift  –  ScatCLI (index-based engine version)
// ============================================================

import Foundation
import ScatEngine

// ── Configuration ───────────────────────────────────────────
let useFixedSeed: Bool = false
let doesClear:    Bool = false

// ── Local player identity (CLI-only mapping layer) ──────────
let playerNames = ["Nathan", "Chloe"] // maps to engine indices

// ── Helpers: terminal ───────────────────────────────────────

func clearScreen() {
    guard doesClear else { return }
    print("\u{1B}[2J\u{1B}[H", terminator: "")
}

func waitForEnter(prompt: String = "Press Enter to continue…") {
    print("\n\(prompt)", terminator: " ")
    _ = readLine()
}

func readInt() -> Int? {
    guard let line = readLine()?.trimmingCharacters(in: .whitespaces) else { return nil }
    return Int(line)
}

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

// ── Display box helpers ─────────────────────────────────────

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

// ── Game display ────────────────────────────────────────────

func printTurnDisplay(engine: ScatEngine) {
    let index = engine.currentPlayerIndex
    let player = engine.players[index]

    print(boxTop())
    print(boxLine("PLAYER INDEX: \(index)  (\(playerNames[index]))"))
    print(boxLine("Chips : \(chipString(player.chips))"))
    print(boxDivider())
    print(boxLine("Draw pile: \(engine.drawPileSize) cards"))
    print(boxLine("Discard top: \(cardString(engine.topOfDiscardPile))"))
    print(boxDivider())
    print(boxLine("Hand:"))

    for (i, card) in player.cards.enumerated() {
        print(boxLine("  \(i + 1). \(cardString(card))"))
    }

    print(boxBottom())
}

// ── Round summary ───────────────────────────────────────────

func snapshotPlayers(_ engine: ScatEngine) -> [Player] {
    engine.players
}

func roundEnded(before: [Player], after: [Player]) -> Bool {
    for (a, b) in zip(before, after) {
        if a.chips != b.chips { return true }
    }
    return false
}

func printRoundSummary(engine: ScatEngine, before: [Player]) {
    let after = engine.players
    let alive = engine.alivePlayerIndices

    banner("── ROUND OVER ──", char: "─")

    print("\nScores:")
    for (i, p) in before.enumerated() {
        print("  \(playerNames[i]) → chips: \(p.chips)")
    }

    print("\nResults:")
    for (i, (old, new)) in zip(before, after).enumerated() {
        if new.chips < old.chips {
            print("  \(playerNames[i]) lost a chip (\(old.chips) → \(new.chips))")
        }
        if !new.isAlive {
            print("  \(playerNames[i]) eliminated!")
        }
    }

    print("\nStill in game:")
    for i in alive {
        print("  \(playerNames[i])")
    }

    waitForEnter()
}

func printGameOver(engine: ScatEngine) {
    clearScreen()
    banner("★ GAME OVER ★")

    let winnerIndex = engine.winnerIndex
    print("\n🏆 Winner: \(playerNames[winnerIndex])")

    print("\nFinal chips:")
    for (i, p) in engine.players.enumerated() {
        print("  \(playerNames[i]) → \(chipString(p.chips))")
    }
}

// ── Entry point ─────────────────────────────────────────────

let seed: UInt64 = useFixedSeed ? 42 : UInt64.random(in: .min ... .max)

var engine = ScatEngine(
    seed: seed,
    playerCount: playerNames.count,
    startingChips: 3
)

_ = engine.startGame()

var knockBannerShown = false

while engine.isActive {
    clearScreen()

    if engine.isKnocked && !knockBannerShown {
        banner("⚑ FINAL ROUND ⚑")
        knockBannerShown = true
    }

    printTurnDisplay(engine: engine)
    print("")

    let beforePlayers = snapshotPlayers(engine)

    print("What would you like to do?")
    var menuOptions: [(key: String, label: String)] = [
        ("1", "Draw a card")
    ]

    if !engine.isKnocked {
        menuOptions.append(("2", "Knock"))
    }

    let choice = readChoice(from: menuOptions)

    if choice == "2" {
        _ = try? engine.makeMove(.knock)
    } else {
        print("\nDraw from:")
        let drawChoice = readChoice(from: [
            ("1", "Draw pile"),
            ("2", "Discard pile")
        ])

        let source: DrawSource = drawChoice == "1" ? .drawPile : .discardPile
        let drawn = source == .drawPile ? engine.topOfDrawPile : engine.topOfDiscardPile

        print("\nYou drew: \(cardString(drawn))")

        let hand = engine.currentPlayer.cards
        let tempHand = hand + [drawn]

        print("\nChoose discard:")
        for (i, c) in tempHand.enumerated() {
            print("  \(i + 1). \(cardString(c))")
        }

        let discardIdx = readIntInRange(lo: 1, hi: tempHand.count,
                                        prompt: "Card to discard:")

        let discard = tempHand[discardIdx - 1]

        _ = try? engine.makeMove(.drawAndDiscard(source: source, discard: discard))
    }

    let afterPlayers = snapshotPlayers(engine)

    if roundEnded(before: beforePlayers, after: afterPlayers) {
        clearScreen()
        printRoundSummary(engine: engine, before: beforePlayers)
        knockBannerShown = false
    }
}

printGameOver(engine: engine)
