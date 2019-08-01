import XCTest
@testable import Shopopoly

class LocationTests: XCTestCase {
    func test_passingFee() {
        XCTAssertEqual(200, Location.testGo.passingFee)
        XCTAssertNil(Location.testFreeParking.passingFee)
        XCTAssertNil(Location.testWarehouse.passingFee)
        XCTAssertNil(Location.testRetail.passingFee)
    }

    func test_rent() {
        XCTAssertNil(Location.testGo.rent)
        XCTAssertNil(Location.testFreeParking.rent)
        XCTAssertEqual(25, Location.testWarehouse.rent)
        XCTAssertEqual(30, Location.testRetail.rent)
    }
    
    func test_canPurchase() {
        XCTAssertFalse(Location.testGo.canPurchase)
        XCTAssertFalse(Location.testFreeParking.canPurchase)
        XCTAssertTrue(Location.testWarehouse.canPurchase)
        XCTAssertTrue(Location.testRetail.canPurchase)
    }
    
    func test_purchasePrice() {
        XCTAssertThrowsError(try Location.testGo.purchasePrice())
        XCTAssertThrowsError(try Location.testFreeParking.purchasePrice())
        XCTAssertEqual(150, try Location.testWarehouse.purchasePrice())
        XCTAssertEqual(200, try Location.testRetail.purchasePrice())
    }
    
    func test_isRetail() {
        XCTAssertFalse(Location.testGo.isRetail)
        XCTAssertFalse(Location.testFreeParking.isRetail)
        XCTAssertFalse(Location.testWarehouse.isRetail)
        XCTAssertTrue(Location.testRetail.isRetail)
    }
    
    func test_updateFee() {
        XCTAssertThrowsError(try Location.testGo.upgradeFee())
        XCTAssertThrowsError(try Location.testFreeParking.upgradeFee())
        XCTAssertThrowsError(try Location.testWarehouse.upgradeFee())
        XCTAssertEqual(50, try Location.testRetail.upgradeFee())
    }
}

extension Location {
    static let testFreeParking = Location.freeParking
    static let testGo = Location.go(fee: 200)
    static let testWarehouse = Location.warehouse(name: "Test Warehouse", purchasePrice: 150, rent: 25)
    static let testRetail = Location.retail(name: "Test Retail Location", purchasePrice: 200, rent: 30, upgradePrice: 50)
}
