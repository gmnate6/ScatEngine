struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed == 0 ? 0x12345678 : seed
    }

    mutating func next() -> UInt64 {
        // simple LCG
        state = 6364136223846793005 &* state &+ 1
        return state
    }
}
