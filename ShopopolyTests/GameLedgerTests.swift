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
        let player1 = try! Player(name: "Bob")
        let players = [player1, try! Player(name: "Steve")]
        let location = Location.testGo
        let locations = [Location.testFreeParking, location, Location.testRetail, Location.testWarehouse]
        var ledger = GameLedger(players: players, locations: locations, dice: [Dice(numberOfSides: 6), Dice(numberOfSides: 6)])
        XCTAssertNoThrow(try ledger.playerReceiveFromBank(player: player1, location: location))
    }
    
    func test_playerPasses_invalidLocation() {
        let player1 = try! Player(name: "Bob")
        let players = [player1, try! Player(name: "Steve")]
        let location = Location.testRetail
        let locations = [Location.testFreeParking, location, Location.testGo, Location.testWarehouse]
        var ledger = GameLedger(players: players, locations: locations, dice: [Dice(numberOfSides: 6), Dice(numberOfSides: 6)])
        XCTAssertThrowsError(try ledger.playerReceiveFromBank(player: player1, location: location))
    }
    
    // MARK: - playerLandedAtLocation
    
    func test_playerLandsAtLocation_paysRent() {
        let player1 = try! Player(name: "Bob")
        let player2 = try! Player(name: "Steve")
        let players = [player1, player2]
        let location = Location.testRetail
        let locations = [Location.testFreeParking, location, Location.testRetail, Location.testWarehouse, Location.testGo]
        var ledger = GameLedger(players: players, locations: locations, dice: [Dice(numberOfSides: 6), Dice(numberOfSides: 6)])
        try! ledger.purchase(player: player2, location: location)
        XCTAssertNoThrow(try ledger.playerLandedAtLocation(player: player1, location: location))
    }
    
    func test_playerLandsAtLocation_ownedBySelf() {
        let player1 = try! Player(name: "Bob")
        let player2 = try! Player(name: "Steve")
        let players = [player1, player2]
        let location = Location.testRetail
        let locations = [Location.testFreeParking, location, Location.testRetail, Location.testWarehouse, Location.testGo]
        var ledger = GameLedger(players: players, locations: locations, dice: [Dice(numberOfSides: 6), Dice(numberOfSides: 6)])
        try! ledger.purchase(player: player1, location: location)
        XCTAssertThrowsError(try ledger.playerLandedAtLocation(player: player1, location: location))
    }
    
    func test_playerLandsAtLocation_unowned() {
        let player1 = try! Player(name: "Bob")
        let players = [player1, try! Player(name: "Steve")]
        let location = Location.testRetail
        let locations = [Location.testFreeParking, location, Location.testRetail, Location.testWarehouse, Location.testGo]
        var ledger = GameLedger(players: players, locations: locations, dice: [Dice(numberOfSides: 6), Dice(numberOfSides: 6)])
        XCTAssertThrowsError(try ledger.playerLandedAtLocation(player: player1, location: location))
    }
    
    func test_playerLandsAtLocation_nonretail() {
        let player1 = try! Player(name: "Bob")
        let players = [player1, try! Player(name: "Steve")]
        let location = Location.testFreeParking
        let locations = [Location.testFreeParking, location, Location.testRetail, Location.testWarehouse, Location.testGo]
        var ledger = GameLedger(players: players, locations: locations, dice: [Dice(numberOfSides: 6), Dice(numberOfSides: 6)])
        XCTAssertThrowsError(try ledger.playerLandedAtLocation(player: player1, location: location))
    }
    
    // MARK: - purchase
    
    func test_purchase_unowned() {
        let player1 = try! Player(name: "Bob")
        let player2 = try! Player(name: "Steve")
        let players = [player1, player2]
        let location = Location.testRetail
        let locations = [Location.testFreeParking, location, Location.testRetail, Location.testWarehouse, Location.testGo]
        var ledger = GameLedger(players: players, locations: locations, dice: [Dice(numberOfSides: 6), Dice(numberOfSides: 6)])
        XCTAssertNoThrow(try ledger.purchase(player: player1, location: location))
    }
    
    func test_purchase_owned() {
        let player1 = try! Player(name: "Bob")
        let player2 = try! Player(name: "Steve")
        let players = [player1, player2]
        let location = Location.testRetail
        let locations = [Location.testFreeParking, location, Location.testRetail, Location.testWarehouse, Location.testGo]
        var ledger = GameLedger(players: players, locations: locations, dice: [Dice(numberOfSides: 6), Dice(numberOfSides: 6)])
        try! ledger.purchase(player: player2, location: location)
        XCTAssertThrowsError(try ledger.purchase(player: player1, location: location))
    }
    
    func test_purchase_freeParking() {
        let player1 = try! Player(name: "Bob")
        let player2 = try! Player(name: "Steve")
        let players = [player1, player2]
        let location = Location.testFreeParking
        let locations = [Location.testFreeParking, location, Location.testRetail, Location.testWarehouse, Location.testGo]
        var ledger = GameLedger(players: players, locations: locations, dice: [Dice(numberOfSides: 6), Dice(numberOfSides: 6)])
        XCTAssertThrowsError(try ledger.purchase(player: player1, location: location))
    }
    
    func test_purchase_with_invalid_player() {
        let player1 = try! Player(name: "Bob")
        let player2 = try! Player(name: "Steve")
        let player3 = try! Player(name: "Geoff")
        let players = [player1, player2]
        let location = Location.testRetail
        let locations = [Location.testFreeParking, location, Location.testRetail, Location.testWarehouse, Location.testGo]
        var ledger = GameLedger(players: players, locations: locations, dice: [Dice(numberOfSides: 6), Dice(numberOfSides: 6)])
        XCTAssertThrowsError(try ledger.purchase(player: player3, location: location))
    }
    
    func test_purchase_with_invalid_location() {
        let player1 = try! Player(name: "Bob")
        let player2 = try! Player(name: "Steve")
        let players = [player1, player2]
        let location = Location.retail(name: "Location not in game", purchasePrice: 250, rent: 75, upgradePrice: 150)
        let locations = [Location.testFreeParking, Location.testRetail, Location.testWarehouse, Location.testGo]
        var ledger = GameLedger(players: players, locations: locations, dice: [Dice(numberOfSides: 6), Dice(numberOfSides: 6)])
        XCTAssertThrowsError(try ledger.purchase(player: player1, location: location))
    }
    
    // MARK: - upgrade
    
    func test_upgrade_unowned() {
        let player1 = try! Player(name: "Bob")
        let player2 = try! Player(name: "Steve")
        let players = [player1, player2]
        let location = Location.testRetail
        let locations = [Location.testFreeParking, location, Location.testRetail, Location.testWarehouse, Location.testGo]
        var ledger = GameLedger(players: players, locations: locations, dice: [Dice(numberOfSides: 6), Dice(numberOfSides: 6)])
        XCTAssertThrowsError(try ledger.upgrade(player: player1, location: location))
    }
    
    func test_upgrade_invalid_owner() {
        let player1 = try! Player(name: "Bob")
        let player2 = try! Player(name: "Steve")
        let players = [player1, player2]
        let location = Location.testRetail
        let locations = [Location.testFreeParking, location, Location.testRetail, Location.testWarehouse, Location.testGo]
        var ledger = GameLedger(players: players, locations: locations, dice: [Dice(numberOfSides: 6), Dice(numberOfSides: 6)])
        try! ledger.purchase(player: player2, location: location)
        XCTAssertThrowsError(try ledger.upgrade(player: player1, location: location))
    }
    
    func test_upgrade_owned() {
        let player1 = try! Player(name: "Bob")
        let player2 = try! Player(name: "Steve")
        let players = [player1, player2]
        let location = Location.testRetail
        let locations = [Location.testFreeParking, location, Location.testRetail, Location.testWarehouse, Location.testGo]
        var ledger = GameLedger(players: players, locations: locations, dice: [Dice(numberOfSides: 6), Dice(numberOfSides: 6)])
        try! ledger.purchase(player: player1, location: location)
        XCTAssertNoThrow(try ledger.upgrade(player: player1, location: location))
    }
    
    func test_upgrade_not_possible() {
        let player1 = try! Player(name: "Bob")
        let player2 = try! Player(name: "Steve")
        let players = [player1, player2]
        let location = Location.testFreeParking
        let locations = [Location.testFreeParking, location, Location.testRetail, Location.testWarehouse, Location.testGo]
        var ledger = GameLedger(players: players, locations: locations, dice: [Dice(numberOfSides: 6), Dice(numberOfSides: 6)])
        XCTAssertThrowsError(try ledger.upgrade(player: player1, location: location))
    }
    
    func test_upgrade_not_possible_max_upgraded() {
        let player1 = try! Player(name: "Bob")
        let player2 = try! Player(name: "Steve")
        let players = [player1, player2]
        let location = Location.testRetail
        let locations = [Location.testFreeParking, location, Location.testRetail, Location.testWarehouse, Location.testGo]
        var ledger = GameLedger(players: players, locations: locations, dice: [Dice(numberOfSides: 6), Dice(numberOfSides: 6)])
        try! ledger.purchase(player: player1, location: location)
        XCTAssertNoThrow(try ledger.upgrade(player: player1, location: location))
        XCTAssertNoThrow(try ledger.upgrade(player: player1, location: location))
        XCTAssertNoThrow(try ledger.upgrade(player: player1, location: location))
        XCTAssertThrowsError(try ledger.upgrade(player: player1, location: location))
    }
    
    // MARK: - mvoe tests
    func test_simple_game_move() {
        let player1 = try! Player(name: "Bob")
        let player2 = try! Player(name: "Steve")
        let players = [player1, player2]
        let locations = GameLedger.testDefaultLocations()
        var ledger = GameLedger(players: players, locations: locations, dice: [Dice(numberOfSides: 6), Dice(numberOfSides: 6)])

        let result = try! ledger.move(player1)
        XCTAssertEqual(2, result.0.count)
        XCTAssertFalse(result.2)
        XCTAssertTrue((1...6).contains(result.0[0]))
        XCTAssertTrue((1...6).contains(result.0[1]))
    }
    
    func test_move_hasPassedGo() {
        let player1 = try! Player(name: "Bob")
        let player2 = try! Player(name: "Steve")
        let players = [player1, player2]
        let locations = GameLedger.testDefaultLocations()
        var ledger = GameLedger(players: players, locations: locations, dice: [Dice(numberOfSides: 6), Dice(numberOfSides: 6)])
        
        var didPassGO = false
        var spacesMoved = 0
        var result = try! ledger.move(player1)
        didPassGO = result.2
        spacesMoved += result.0.reduce(0) { $0 + $1 }
        
        while !didPassGO {
            result = try! ledger.move(player1)
            didPassGO = result.2
            spacesMoved += result.0.reduce(0) { $0 + $1 }
        }

        XCTAssertTrue(didPassGO)
        XCTAssertTrue(spacesMoved >= locations.count)
    }
    
    func test_game_move_invalid_player() {
        let player1 = try! Player(name: "Bob")
        let player2 = try! Player(name: "Steve")
        let player3 = try! Player(name: "Rachel")
        let players = [player1, player2]
        let locations = GameLedger.testDefaultLocations()
        var ledger = GameLedger(players: players, locations: locations, dice: [Dice(numberOfSides: 6), Dice(numberOfSides: 6)])
        
        XCTAssertThrowsError(try ledger.move(player3))
    }
}

extension GameLedger {
    static func testDefaultLocations() -> [Location] {
        return [
            .testGo,
            .retail(name: "Old Kent Road", purchasePrice: 60, rent: 2, upgradePrice: 50),
            .communityChest,
            .retail(name: "Whitechapel Road", purchasePrice: 60, rent: 4, upgradePrice: 50),
            .incomeTax(name: "Income Tax", fee: 200),
            .warehouse(name: "Kings Cross Station", purchasePrice: 200, rent: 50),
            .retail(name: "The Angel Islington", purchasePrice: 100, rent: 10, upgradePrice: 50),
            .chance,
            .retail(name: "Euston Road", purchasePrice: 100, rent: 10, upgradePrice: 50),
            .retail(name: "Pentonville Road", purchasePrice: 120, rent: 12, upgradePrice: 50),
            .jail,
            
            .retail(name: "Pall Mall", purchasePrice: 140, rent: 14, upgradePrice: 150),
            .warehouse(name: "Electric Works", purchasePrice: 150, rent: 50),
            .retail(name: "Whitehall", purchasePrice: 140, rent: 14, upgradePrice: 150),
            .retail(name: "Northumberland Avenue", purchasePrice: 160, rent: 16, upgradePrice: 150),
            .warehouse(name: "Marylebone Station", purchasePrice: 200, rent: 200),
            .retail(name: "Bow Street", purchasePrice: 180, rent: 18, upgradePrice: 150),
            .communityChest,
            .retail(name: "Marylebone Street", purchasePrice: 180, rent: 18, upgradePrice: 150),
            .retail(name: "Vine Street", purchasePrice: 200, rent: 20, upgradePrice: 150),
            .freeParking,
            
            .retail(name: "Strand", purchasePrice: 220, rent: 22, upgradePrice: 150),
            .chance,
            .retail(name: "Fleet Street", purchasePrice: 220, rent: 22, upgradePrice: 150),
            .retail(name: "Trafalgar Square", purchasePrice: 240, rent: 24, upgradePrice: 150),
            .warehouse(name: "Fenchurch Street Station", purchasePrice: 200, rent: 200),
            .retail(name: "Leicester Square", purchasePrice: 260, rent: 26, upgradePrice: 150),
            .retail(name: "Coventry Street", purchasePrice: 260, rent: 26, upgradePrice: 150),
            .warehouse(name: "Water Works", purchasePrice: 150, rent: 50),
            .retail(name: "Picadilly", purchasePrice: 280, rent: 28, upgradePrice: 150),
            .goToJail,
            
            .retail(name: "Regent Street", purchasePrice: 300, rent: 30, upgradePrice: 200),
            .retail(name: "Oxford Street", purchasePrice: 300, rent: 30, upgradePrice: 200),
            .communityChest,
            .retail(name: "Bond Street", purchasePrice: 320, rent: 32, upgradePrice: 200),
            .warehouse(name: "Liverpool Street Station", purchasePrice: 200, rent: 200),
            .chance,
            .retail(name: "Park Lane", purchasePrice: 350, rent: 35, upgradePrice: 200),
            .incomeTax(name: "Super Tax", fee: 100),
            .retail(name: "Mayfair", purchasePrice: 400, rent: 40, upgradePrice: 200),
        ]
    }
    
    static let testEmptyLedger: GameLedger = {
        let ledger = GameLedger(players: [], locations: [], dice: [])
        return ledger
    }()
    
    static let testPopulatedLedger: GameLedger = {
        let players = [try! Player(name: "Bob"), try! Player(name: "Steve")]
        let locations = [Location.testFreeParking, Location.testGo, Location.testRetail, Location.testWarehouse]
        let ledger = GameLedger(players: players, locations: locations, dice: [Dice(numberOfSides: 6), Dice(numberOfSides: 6)])
        return ledger
    }()
}
