typealias Money = Int

struct GameLedger: Codable {
    enum Errors: Error {
        case invalidPlayer
        case invalidLocation
        case locationUnowned
        case cannotUpgrade
        case cannotPurchase
        case noRentDue
        case noPassingFee
    }
    
    private struct PlayerData: Codable {
        let player: Player
        var money: Money
    }
    
    private struct LocationData: Codable {
        let location: Location
        var owner: Player?
        var retailType: RetailType = .none

        var canPurchase: Bool {
            return owner == nil
        }
    }
    
    fileprivate enum Transaction {
        case startGame(value: Money)
        case passLocation(player: Player, location: Location)
        case landOnLocation(player: Player, location: Location)
        case purchase(player: Player, location: Location)
        case upgrade(player: Player, location: Location)
    }
    
    private var playerData: [PlayerData]
    private var locationData: [LocationData]
    private var transactions: [Transaction]
    
    init(players: [Player], locations: [Location]) {
        playerData = players.map {
            PlayerData(player: $0, money: 0)
        }
        
        locationData = locations.map {
            LocationData(location: $0, owner: nil, retailType: .none)
        }
        
        transactions = []
    }
}

// MARK: - Public Functions
extension GameLedger {
    /// A function that adds a transaction for an amount being transferred from the Bank to a Player. This is the starting balance for each player in the game.
    /// - Parameter value: starting balance of each player
    mutating func startGame(value: Money) throws {
        try process(.startGame(value: value))
    }
    
    /// A function that adds a transaction for the Bank paying a fee to a Player, e.g. when the player passes through the Go location.
    /// - Parameter player: player receiving a fee from the bank
    /// - Parameter location: location player passing
    mutating func playerReceiveFromBank(player: Player, location: Location) throws {
        try process(.passLocation(player: player, location: location))
    }
    
    /// A function that adds a transaction for rent being paid from one player to another, e.g. when a player lands on a RetailSite location owned by another player.
    /// - Parameter player: player landing at location
    /// - Parameter location: location player landed on
    mutating func playerLandedAtLocation(player: Player, location: Location) throws {
        try process(.landOnLocation(player: player, location: location))
    }
    
    /// A function that adds a transaction for when a Player has paid the Bank to purchase a Location.
    /// - Parameter player: player making purchase
    /// - Parameter location: location to purchase
    mutating func purchase(player: Player, location: Location) throws {
        try process(.purchase(player: player, location: location))
    }
    
    /// A function that adds a transaction for when a Player has paid the Bank for building a specific type of building on a Location. Types of building include ministore, supermarket or megastore.
    /// - Parameter player: player building up location
    /// - Parameter location: location at which to build
    mutating func upgrade(player: Player, location: Location) throws {
        try process(.upgrade(player: player, location: location))
    }
}

// MARK: - Private Functions
extension GameLedger {
    private mutating func process(_ transaction: Transaction) throws {
        transactions.append(transaction)
        
        switch transaction {
        
        case .startGame(let value):
            for i in 0..<playerData.count {
                processTransactionDetail(playerIndex: i, value: value)
            }
        
        case .passLocation(let player, let location):
            guard let passingFee = location.passingFee else { throw Errors.noPassingFee }
            let playerIndex = try indexOf(player: player)
            processTransactionDetail(playerIndex: playerIndex, value: passingFee)
        
        case .landOnLocation(let player, let location):
            let locationIndex = try indexOf(location: location)
            let data = locationData[locationIndex]
            guard let locationPlayer = data.owner else { throw Errors.locationUnowned }
            guard let rent = location.rent, data.owner != player else { throw Errors.noRentDue }
            processTransactionDetail(playerIndex: try indexOf(player: player), value: -rent)
            processTransactionDetail(playerIndex: try indexOf(player: locationPlayer), value: rent)
        
        case .purchase(let player, let location):
            guard location.canPurchase else { throw Errors.cannotPurchase }
            let locationIndex = try indexOf(location: location)
            var data = locationData[locationIndex]
            guard data.canPurchase else { throw Errors.cannotPurchase }
            let purchaseFee = try location.purchasePrice()
            let playerIndex = try indexOf(player: player)
            processTransactionDetail(playerIndex: playerIndex, value: -purchaseFee)
            data.owner = player
            locationData[locationIndex] = data
        
        case .upgrade(let player, let location):
            let locationIndex = try indexOf(location: location)
            var data = locationData[locationIndex]
            guard location.isRetail, data.retailType.canUpgrade, data.owner == player else { throw Errors.cannotUpgrade }
            let upgradeFee = try location.upgradeFee()
            let playerIndex = try indexOf(player: player)
            processTransactionDetail(playerIndex: playerIndex, value: -upgradeFee)
            data.retailType = data.retailType.upgradedValue()
            locationData[locationIndex] = data
        }
    }
    
    private mutating func processTransactionDetail(playerIndex: Int, value: Money) {
        var data = playerData[playerIndex]
        data.money += value
        playerData[playerIndex] = data
    }
    
    private func indexOf(player: Player) throws -> Int {
        let index = playerData.firstIndex {
            $0.player == player
        }
        guard let i = index else { throw Errors.invalidPlayer }
        return i
    }
    
    private func indexOf(location: Location) throws -> Int {
        let index = locationData.firstIndex {
            $0.location == location
        }
        guard let i = index else { throw Errors.invalidLocation }
        return i
    }
}

/*
 enum Transaction {
 case startGame(value: Money)
 case passLocation(player: Player, location: Location)
 case landOnLocation(player: Player, location: Location)
 case purchase(player: Player, location: Location)
 case upgrade(player: Player, location: Location)
 }
 */
extension GameLedger.Transaction: Codable {
    enum CodingKeys: String, CodingKey {
        case transactionOption
        case value
        case player, location
    }
    
    private enum TransactionOption: String, Codable {
        case startGame, passLocation, landOnLocation, purchase, upgrade
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let option = try container.decode(TransactionOption.self, forKey: .transactionOption)
        
        switch option {
        case .startGame:
            let value = try container.decode(Money.self, forKey: .value)
            self = .startGame(value: value)
        case .passLocation:
            let player = try container.decode(Player.self, forKey: .player)
            let location = try container.decode(Location.self, forKey: .location)
            self = .passLocation(player: player, location: location)
        case .landOnLocation:
            let player = try container.decode(Player.self, forKey: .player)
            let location = try container.decode(Location.self, forKey: .location)
            self = .landOnLocation(player: player, location: location)
        case .purchase:
            let player = try container.decode(Player.self, forKey: .player)
            let location = try container.decode(Location.self, forKey: .location)
            self = .purchase(player: player, location: location)
        case .upgrade:
            let player = try container.decode(Player.self, forKey: .player)
            let location = try container.decode(Location.self, forKey: .location)
            self = .upgrade(player: player, location: location)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .startGame(let value):
            try container.encode(TransactionOption.startGame, forKey: .transactionOption)
            try container.encode(value, forKey: .value)
        case .passLocation(let player, let location):
            try container.encode(TransactionOption.passLocation, forKey: .transactionOption)
            try container.encode(player, forKey: .player)
            try container.encode(location, forKey: .location)
        case .landOnLocation(let player, let location):
            try container.encode(TransactionOption.landOnLocation, forKey: .transactionOption)
            try container.encode(player, forKey: .player)
            try container.encode(location, forKey: .location)
        case .purchase(let player, let location):
            try container.encode(TransactionOption.purchase, forKey: .transactionOption)
            try container.encode(player, forKey: .player)
            try container.encode(location, forKey: .location)
        case .upgrade(let player, let location):
            try container.encode(TransactionOption.upgrade, forKey: .transactionOption)
            try container.encode(player, forKey: .player)
            try container.encode(location, forKey: .location)
        }
    }
}
