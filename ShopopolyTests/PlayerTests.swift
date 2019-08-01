import XCTest
@testable import Shopopoly

class PlayerTests: XCTestCase {
    func test_player() {
        let name = "Bob"
        let player = Player(name: name)
        XCTAssertEqual(name, player.name)
    }
}
