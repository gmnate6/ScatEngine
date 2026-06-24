public enum ScatError: Error {
    case gameAlreadyOver
    case notYourTurn
    case invalidAction
    case playerNotFound
    case playerKnockedDuringKnock
    case playerDiscardedCardTheyDontHave
    case playerEliminated
}
