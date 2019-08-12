import XCTest
@testable import Shopopoly

class CodableTests: XCTestCase {
    func test_simple_ledger() {
        let ledger = GameLedger.testPopulatedLedger
        let data = try! JSONEncoder().encode(ledger)
        XCTAssertNotNil(data)
        
        let ledgerResumed = try! JSONDecoder().decode(GameLedger.self, from: data)
        XCTAssertNotNil(ledgerResumed)
    }
    
    func test_ledger_with_transactions() {
        let player1 = try! Player(name: "Bob")
        let player2 = try! Player(name: "Steve")
        let players = [player1, player2]
        
        let retailLocation = Location.testRetail
        let goLocation = Location.testGo
        
        let locations: [Location] = [
            .chance,
            .communityChest,
            .freeParking,
            .testGo,
            .goToJail,
            .incomeTax(name: "tax 1", fee: 100),
            .jail,
            .testRetail,
            .testWarehouse,
            retailLocation,
            goLocation,
        ]
        var ledger = GameLedger(players: players, locations: locations, dice: [Dice(numberOfSides: 6), Dice(numberOfSides: 6)])
        try! ledger.startGame(value: 1500)
        try! ledger.purchase(player: player1, location: retailLocation)
        try! ledger.playerReceiveFromBank(player: player1, location: goLocation)
        try! ledger.upgrade(player: player1, location: retailLocation)
        try! ledger.playerLandedAtLocation(player: player2, location: retailLocation)
        _ = try! ledger.moveCurrentPlayer()
        
        let data = try! JSONEncoder().encode(ledger)
        XCTAssertNotNil(data)
        
        let ledgerResumed = try! JSONDecoder().decode(GameLedger.self, from: data)
        XCTAssertNotNil(ledgerResumed)
    }
}
