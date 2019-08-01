import XCTest
@testable import Shopopoly

class GameLedgerTests: XCTestCase {
    func test_initialisation_blank() {
        let ledger = GameLedger.testEmptyLedger
        XCTAssertNotNil(ledger)
    }
    
    func test_initialisation_withData() {
        let ledger = GameLedger.testPopulatedLedger
        XCTAssertNotNil(ledger)
    }
    
    // MARK: - startGame
    
    func test_startGame() {
        var ledger = GameLedger.testPopulatedLedger
        XCTAssertNoThrow(try ledger.startGame(value: 1500))
    }
    
    // MARK: - playerReceiveFromBank
    
    func test_playerPassesGo() {
        let player1 = Player(name: "Bob")
        let players = [player1, Player(name: "Steve")]
        let location = Location.testGo
        let locations = [Location.testFreeParking, location, Location.testRetail, Location.testWarehouse]
        var ledger = GameLedger(players: players, locations: locations)
        XCTAssertNoThrow(try ledger.playerReceiveFromBank(player: player1, location: location))
    }
    
    func test_playerPasses_invalidLocation() {
        let player1 = Player(name: "Bob")
        let players = [player1, Player(name: "Steve")]
        let location = Location.testRetail
        let locations = [Location.testFreeParking, location, Location.testGo, Location.testWarehouse]
        var ledger = GameLedger(players: players, locations: locations)
        XCTAssertThrowsError(try ledger.playerReceiveFromBank(player: player1, location: location))
    }
    
    // MARK: - playerLandedAtLocation
    
    func test_playerLandsAtLocation_paysRent() {
        let player1 = Player(name: "Bob")
        let player2 = Player(name: "Steve")
        let players = [player1, player2]
        let location = Location.testRetail
        let locations = [Location.testFreeParking, location, Location.testRetail, Location.testWarehouse, Location.testGo]
        var ledger = GameLedger(players: players, locations: locations)
        try! ledger.purchase(player: player2, location: location)
        XCTAssertNoThrow(try ledger.playerLandedAtLocation(player: player1, location: location))
    }
    
    func test_playerLandsAtLocation_ownedBySelf() {
        let player1 = Player(name: "Bob")
        let player2 = Player(name: "Steve")
        let players = [player1, player2]
        let location = Location.testRetail
        let locations = [Location.testFreeParking, location, Location.testRetail, Location.testWarehouse, Location.testGo]
        var ledger = GameLedger(players: players, locations: locations)
        try! ledger.purchase(player: player1, location: location)
        XCTAssertThrowsError(try ledger.playerLandedAtLocation(player: player1, location: location))
    }
    
    func test_playerLandsAtLocation_unowned() {
        let player1 = Player(name: "Bob")
        let players = [player1, Player(name: "Steve")]
        let location = Location.testRetail
        let locations = [Location.testFreeParking, location, Location.testRetail, Location.testWarehouse, Location.testGo]
        var ledger = GameLedger(players: players, locations: locations)
        XCTAssertThrowsError(try ledger.playerLandedAtLocation(player: player1, location: location))
    }
    
    func test_playerLandsAtLocation_nonretail() {
        let player1 = Player(name: "Bob")
        let players = [player1, Player(name: "Steve")]
        let location = Location.testFreeParking
        let locations = [Location.testFreeParking, location, Location.testRetail, Location.testWarehouse, Location.testGo]
        var ledger = GameLedger(players: players, locations: locations)
        XCTAssertThrowsError(try ledger.playerLandedAtLocation(player: player1, location: location))
    }
    
    // MARK: - purchase
    
    func test_purchase_unowned() {
        let player1 = Player(name: "Bob")
        let player2 = Player(name: "Steve")
        let players = [player1, player2]
        let location = Location.testRetail
        let locations = [Location.testFreeParking, location, Location.testRetail, Location.testWarehouse, Location.testGo]
        var ledger = GameLedger(players: players, locations: locations)
        XCTAssertNoThrow(try ledger.purchase(player: player1, location: location))
    }
    
    func test_purchase_owned() {
        let player1 = Player(name: "Bob")
        let player2 = Player(name: "Steve")
        let players = [player1, player2]
        let location = Location.testRetail
        let locations = [Location.testFreeParking, location, Location.testRetail, Location.testWarehouse, Location.testGo]
        var ledger = GameLedger(players: players, locations: locations)
        try! ledger.purchase(player: player2, location: location)
        XCTAssertThrowsError(try ledger.purchase(player: player1, location: location))
    }
    
    func test_purchase_freeParking() {
        let player1 = Player(name: "Bob")
        let player2 = Player(name: "Steve")
        let players = [player1, player2]
        let location = Location.testFreeParking
        let locations = [Location.testFreeParking, location, Location.testRetail, Location.testWarehouse, Location.testGo]
        var ledger = GameLedger(players: players, locations: locations)
        XCTAssertThrowsError(try ledger.purchase(player: player1, location: location))
    }
    
    func test_purchase_with_invalid_player() {
        let player1 = Player(name: "Bob")
        let player2 = Player(name: "Steve")
        let player3 = Player(name: "Geoff")
        let players = [player1, player2]
        let location = Location.testRetail
        let locations = [Location.testFreeParking, location, Location.testRetail, Location.testWarehouse, Location.testGo]
        var ledger = GameLedger(players: players, locations: locations)
        XCTAssertThrowsError(try ledger.purchase(player: player3, location: location))
    }
    
    func test_purchase_with_invalid_location() {
        let player1 = Player(name: "Bob")
        let player2 = Player(name: "Steve")
        let players = [player1, player2]
        let location = Location.retail(name: "Location not in game", purchasePrice: 250, rent: 75, upgradePrice: 150)
        let locations = [Location.testFreeParking, Location.testRetail, Location.testWarehouse, Location.testGo]
        var ledger = GameLedger(players: players, locations: locations)
        XCTAssertThrowsError(try ledger.purchase(player: player1, location: location))
    }
    
    // MARK: - upgrade
    
    func test_upgrade_unowned() {
        let player1 = Player(name: "Bob")
        let player2 = Player(name: "Steve")
        let players = [player1, player2]
        let location = Location.testRetail
        let locations = [Location.testFreeParking, location, Location.testRetail, Location.testWarehouse, Location.testGo]
        var ledger = GameLedger(players: players, locations: locations)
        XCTAssertThrowsError(try ledger.upgrade(player: player1, location: location))
    }
    
    func test_upgrade_invalid_owner() {
        let player1 = Player(name: "Bob")
        let player2 = Player(name: "Steve")
        let players = [player1, player2]
        let location = Location.testRetail
        let locations = [Location.testFreeParking, location, Location.testRetail, Location.testWarehouse, Location.testGo]
        var ledger = GameLedger(players: players, locations: locations)
        try! ledger.purchase(player: player2, location: location)
        XCTAssertThrowsError(try ledger.upgrade(player: player1, location: location))
    }
    
    func test_upgrade_owned() {
        let player1 = Player(name: "Bob")
        let player2 = Player(name: "Steve")
        let players = [player1, player2]
        let location = Location.testRetail
        let locations = [Location.testFreeParking, location, Location.testRetail, Location.testWarehouse, Location.testGo]
        var ledger = GameLedger(players: players, locations: locations)
        try! ledger.purchase(player: player1, location: location)
        XCTAssertNoThrow(try ledger.upgrade(player: player1, location: location))
    }
    
    func test_upgrade_not_possible() {
        let player1 = Player(name: "Bob")
        let player2 = Player(name: "Steve")
        let players = [player1, player2]
        let location = Location.testFreeParking
        let locations = [Location.testFreeParking, location, Location.testRetail, Location.testWarehouse, Location.testGo]
        var ledger = GameLedger(players: players, locations: locations)
        XCTAssertThrowsError(try ledger.upgrade(player: player1, location: location))
    }
    
    func test_upgrade_not_possible_max_upgraded() {
        let player1 = Player(name: "Bob")
        let player2 = Player(name: "Steve")
        let players = [player1, player2]
        let location = Location.testRetail
        let locations = [Location.testFreeParking, location, Location.testRetail, Location.testWarehouse, Location.testGo]
        var ledger = GameLedger(players: players, locations: locations)
        try! ledger.purchase(player: player1, location: location)
        XCTAssertNoThrow(try ledger.upgrade(player: player1, location: location))
        XCTAssertNoThrow(try ledger.upgrade(player: player1, location: location))
        XCTAssertNoThrow(try ledger.upgrade(player: player1, location: location))
        XCTAssertThrowsError(try ledger.upgrade(player: player1, location: location))
    }
}

extension GameLedger {
    static let testEmptyLedger: GameLedger = {
        let ledger = GameLedger(players: [], locations: [])
        return ledger
    }()
    
    static let testPopulatedLedger: GameLedger = {
        let players = [Player(name: "Bob"), Player(name: "Steve")]
        let locations = [Location.testFreeParking, Location.testGo, Location.testRetail, Location.testWarehouse]
        let ledger = GameLedger(players: players, locations: locations)
        return ledger
    }()
}
