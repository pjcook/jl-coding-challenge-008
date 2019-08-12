public typealias Money = Int

public struct GameLedger: Codable {
    public enum Errors: Error {
        case invalidPlayer
        case invalidLocation
        case locationUnowned
        case cannotUpgrade
        case cannotPurchase
        case noRentDue
        case noPassingFee
        case currentPlayerAlreadyMoved
    }
    
    public enum Action: Int, Codable {
        case none
        case canPurchase
        case canUpgrade
    }
    
    public enum PlayerState: Int, Codable {
        case playing
        case outOfGame
    }
    
    public struct PlayerData: Codable {
        public let player: Player
        public var money: Money
        public var boardLocation: Int
        public var state: PlayerState = .playing
    }
    
    public struct LocationData: Codable {
        let location: Location
        var owner: Player?
        var retailType: RetailType = .none

        var canPurchase: Bool {
            return owner == nil && location.canPurchase
        }
    }
    
    fileprivate enum Transaction {
        case startGame(value: Money)
        case passLocation(player: Player, location: Location)
        case landOnLocation(player: Player, location: Location)
        case purchase(player: Player, location: Location)
        case upgrade(player: Player, location: Location)
        case move(player: Player, rolls: [Int], startIndex: Int, endIndex: Int, didPassGO: Bool)
    }
    
    public private(set) var currentPlayerMoved = false
    private var currentPlayerIndex = 0
    private var playerData: [PlayerData]
    private var locationData: [LocationData]
    private var transactions: [Transaction]
    private let dice: [Dice]
    
    public init(players: [Player], locations: [Location], dice: [Dice]) {
        self.dice = dice
        playerData = players.map {
            PlayerData(player: $0, money: 0, boardLocation: 0, state: .playing)
        }
        
        locationData = locations.map {
            LocationData(location: $0, owner: nil, retailType: .none)
        }
        
        transactions = []
    }
}

// MARK: - Public Functions
public extension GameLedger {
    var currentPlayerData: PlayerData {
        return playerData[currentPlayerIndex]
    }

    func getPlayers() -> [Player] {
        return playerData.map { $0.player }
    }
    
    func getPlayerData() -> [PlayerData] {
        return playerData
    }
    
    func getLocationData() -> [LocationData] {
        return locationData
    }
    
    func actions(for location: Location, player: Player) throws -> [Action] {
        _ = try indexOf(player: player)
        let locationIndex = try indexOf(location: location)
        let data = locationData[locationIndex]
        
        if data.owner == nil, data.canPurchase {
            return [.canPurchase]
        }
        
        if data.owner == player, data.retailType.canUpgrade {
            return [.canUpgrade]
        }
        
        return [.none]
    }
    
    /// Pass play to the next player
    mutating func endTurn() {
        currentPlayerIndex += 1
        if currentPlayerIndex >= playerData.count {
            currentPlayerIndex = 0
        }
        currentPlayerMoved = false
    }
    
    /// Move the next player
    ///
    /// - Returns: The values from each Die rolled, the location the player lands on, whether the player passed GO or not
    mutating func moveCurrentPlayer() throws -> ([Int], Location, Bool) {
        guard currentPlayerIndex < playerData.count else { throw Errors.invalidPlayer }
        guard currentPlayerMoved == false else { throw Errors.currentPlayerAlreadyMoved }
        currentPlayerMoved = true
        return try move(currentPlayerData.player)
    }
    
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
    /// The game of Shopopoly requires the player to shake two 6 sided dice and move forward by the total number of the two dice. The Dice data type contains two integer values between one and six, one for each dice. The two values are generated randomly when an instance of Dice is created.
    
    /// To enable a player to move a function needs to be created that adds the Dice to the boardLocation to create a new boardLocation for the player. Locations are organised in a loop so when you move past the last Location, you move onto the first Location.
    ///
    /// - Parameter player: The player currently moving
    /// - Returns: The values from each Die rolled, the location the player lands on, whether the player passed GO or not
    private mutating func move(_ player: Player) throws -> ([Int], Location, Bool) {
        let playerIndex = try indexOf(player: player)
        var data = playerData[playerIndex]
        let rolls = dice.map { $0.roll() }
        let startIndex = data.boardLocation
        var endIndex = startIndex + rolls.reduce(0) { $0 + $1 }
        if endIndex > locationData.count - 1 {
            endIndex = endIndex % locationData.count
        }
        data.boardLocation = endIndex
        playerData[playerIndex] = data
        let didPassGO = hasPassedGo(startIndex, endIndex)
        
        try process(.move(player: player, rolls: rolls, startIndex: startIndex, endIndex: endIndex, didPassGO: didPassGO))
        
        return (rolls, locationData[endIndex].location, didPassGO)
    }
    
    /// To detect whether a player has passed go (i.e. landed on the go square or passed over it) a function needs to be created that accepts two boardLocations as input and returns true if the player has passed go. Please assume the board has at least 13 Locations on it so you can’t pass through go more than once in one move.
    ///
    /// - Parameters:
    ///   - startIndex: Players start location index
    ///   - endIndex: Players end location index
    /// - Returns: Whether the player passed GO or not
    private mutating func hasPassedGo(_ startIndex: Int, _ endIndex: Int) -> Bool {
        var hasPassedGO = false
        var indices: FlattenSequence<[Range<Int>]>
        if startIndex < endIndex {
            indices = [(startIndex+1..<endIndex)].joined()
        } else {
            indices = [(startIndex+1..<locationData.count), (0..<endIndex)].joined()
        }

        for i in indices {
            if case .go = locationData[i].location {
                hasPassedGO = true
                break
            }
        }
        return hasPassedGO
    }
    
    private func findLocationGO() -> Location? {
        return locationData.first(where: { data in
            if case .go = data.location { return true }
            return false
        })?.location
    }
    
    private mutating func process(_ transaction: Transaction) throws {
        transactions.append(transaction)
        
        switch transaction {
        case .move(let player, _, _, let endIndex, let didPassGo):
            let data = locationData[endIndex]
            let playerIndex = try indexOf(player: player)
            
            if didPassGo, let go = findLocationGO(), let passingFee = go.passingFee {
                processTransactionDetail(playerIndex: playerIndex, value: passingFee)
            }
            
            if data.owner != nil, data.owner != player {
                try process(.landOnLocation(player: player, location: data.location))
            }
            
            break
        
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
        case player, location, dice
        case rolls, startIndex, endIndex, didPassGO
    }
    
    private enum TransactionOption: String, Codable {
        case startGame, passLocation, landOnLocation, purchase, upgrade, move
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let option = try container.decode(TransactionOption.self, forKey: .transactionOption)
        
        switch option {
        case .move:
            let player = try container.decode(Player.self, forKey: .player)
            let rolls = try container.decode(Array<Int>.self, forKey: .rolls)
            let startIndex = try container.decode(Int.self, forKey: .startIndex)
            let endIndex = try container.decode(Int.self, forKey: .endIndex)
            let didPassGO = try container.decode(Bool.self, forKey: .didPassGO)
            self = .move(player: player, rolls: rolls, startIndex: startIndex, endIndex: endIndex, didPassGO: didPassGO)
            
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
        case .move(let player, let rolls, let startIndex, let endIndex, let didPassGO):
            try container.encode(TransactionOption.move, forKey: .transactionOption)
            try container.encode(player, forKey: .player)
            try container.encode(rolls, forKey: .rolls)
            try container.encode(startIndex, forKey: .startIndex)
            try container.encode(endIndex, forKey: .endIndex)
            try container.encode(didPassGO, forKey: .didPassGO)
            
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
