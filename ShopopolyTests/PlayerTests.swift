import XCTest
@testable import Shopopoly

class PlayerTests: XCTestCase {
    func test_player() {
        let name = "Bob"
        let player = try! Player(name: name)
        XCTAssertEqual(name, player.name)
    }
    
    func test_player_with_blank_name() {
        XCTAssertThrowsError(try Player(name: ""))
    }
    
    func test_player_with_too_long_name() {
        XCTAssertThrowsError(try Player(name: "Steve Steve Steve Steve Steve Steve Steve Steve Steve Steve "))
    }
    
    func test_player_with_valid_name() {
        XCTAssertNoThrow(try Player(name: "Steve"))
    }
}
