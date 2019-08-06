import XCTest
@testable import Shopopoly

class DiceTests: XCTestCase {
    let numberOfSides = 6
    let dice = Dice(numberOfSides: 6)
    func test_roll() {
        for _ in 0..<10 {
            XCTAssertTrue((1...numberOfSides).contains(dice.roll()))
        }
    }
}
