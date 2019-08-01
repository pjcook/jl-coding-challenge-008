import XCTest
@testable import Shopopoly

class RetailTypeTests: XCTestCase {
    func test_values_count() {
        XCTAssertEqual(4, RetailType.allCases.count)
    }
    
    func test_canUpgrade() {
        XCTAssertTrue(RetailType.none.canUpgrade)
        XCTAssertTrue(RetailType.ministore.canUpgrade)
        XCTAssertTrue(RetailType.supermarket.canUpgrade)
        XCTAssertFalse(RetailType.megastore.canUpgrade)
    }
    
    func test_upgradedValue() {
        XCTAssertEqual(RetailType.ministore, RetailType.none.upgradedValue())
        XCTAssertEqual(RetailType.supermarket, RetailType.ministore.upgradedValue())
        XCTAssertEqual(RetailType.megastore, RetailType.supermarket.upgradedValue())
        XCTAssertEqual(RetailType.megastore, RetailType.megastore.upgradedValue())
    }
}
