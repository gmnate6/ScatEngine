import Testing
@testable import ScatEngine

struct SeededGeneratorTests {
    @Test
    func generatorIsDeterministicForSameSeed() {
        var g1 = SeededGenerator(seed: 123)
        var g2 = SeededGenerator(seed: 123)

        let sequence1 = (0..<5).map { _ in g1.next() }
        let sequence2 = (0..<5).map { _ in g2.next() }

        #expect(sequence1 == sequence2)
    }
}
