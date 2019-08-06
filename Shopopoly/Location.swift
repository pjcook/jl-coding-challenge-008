import Foundation

enum RetailType: Int, Codable, CaseIterable {
    case none, ministore, supermarket, megastore
    
    var canUpgrade: Bool {
        return self != .megastore
    }
    
    func upgradedValue() -> RetailType {
        return RetailType(rawValue: self.rawValue + 1) ?? .megastore
    }
}

enum Location: Equatable {
    enum Errors: Error {
        case cannotPurchase
        case cannotUpgrade
    }

    case freeParking
    case communityChest
    case chance
    case jail
    case goToJail
    case incomeTax(name: String, fee: Money)
    case go(fee: Money)
    case warehouse(name: String, purchasePrice: Money, rent: Money)
    case retail(name: String, purchasePrice: Money, rent: Money, upgradePrice: Money)
}

// MARK: - additional logic
extension Location {
    var passingFee: Money? {
        switch self {
        case .go(let fee):
            return fee
        default: return nil
        }
    }
    
    var rent: Money? {
        switch self {
        case .freeParking, .go, .chance, .communityChest, .jail, .goToJail, .incomeTax:
            return nil
        case .warehouse(_, _, let rent):
            return rent
        case .retail(_, _, let rent, _):
            return rent
        }
    }
    
    var canPurchase: Bool {
        switch self {
        case .warehouse, .retail: return true
        default: return false
        }
    }
    
    func purchasePrice() throws -> Money {
        switch self {
        case .warehouse(_, let purchasePrice, _):
            return purchasePrice
        case .retail(_, let purchasePrice, _, _):
            return purchasePrice
        default: throw Errors.cannotPurchase
        }
    }
    
    var isRetail: Bool {
        switch self {
        case .retail: return true
        default: return false
        }
    }
    
    func upgradeFee() throws -> Money {
        switch self {
        case .retail(_, _, _, let upgradePrice):
            return upgradePrice
        default: throw Errors.cannotUpgrade
        }
    }
}

// MARK: - Codable
extension Location: Codable {
    enum CodingKeys: String, CodingKey {
        case locationOption
        case fee
        case name, purchasePrice, rent, upgradePrice
    }
    
    private enum LocationOption: String, Codable {
        case freeParking, go, warehouse, retail, chance, communityChest, jail, goToJail, incomeTax
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let locationOption = try container.decode(LocationOption.self, forKey: .locationOption)
        
        switch locationOption {
        case .freeParking:
            self = .freeParking
            
        case .communityChest:
            self = .communityChest
            
        case .chance:
            self = .chance
            
        case .jail:
            self = .jail
            
        case .goToJail:
            self = .goToJail
            
        case .incomeTax:
            let name = try container.decode(String.self, forKey: .name)
            let fee = try container.decode(Money.self, forKey: .fee)
            self = .incomeTax(name: name, fee: fee)
        
        case .go:
            let fee = try container.decode(Money.self, forKey: .fee)
            self = .go(fee: fee)
        
        case .warehouse:
            let name = try container.decode(String.self, forKey: .name)
            let purchasePrice = try container.decode(Money.self, forKey: .purchasePrice)
            let rent = try container.decode(Money.self, forKey: .rent)
            self = .warehouse(name: name, purchasePrice: purchasePrice, rent: rent)
        
        case .retail:
            let name = try container.decode(String.self, forKey: .name)
            let purchasePrice = try container.decode(Money.self, forKey: .purchasePrice)
            let rent = try container.decode(Money.self, forKey: .rent)
            let upgradePrice = try container.decode(Money.self, forKey: .upgradePrice)
            self = .retail(name: name, purchasePrice: purchasePrice, rent: rent, upgradePrice: upgradePrice)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .freeParking:
            try container.encode(LocationOption.freeParking, forKey: .locationOption)
            
        case .communityChest:
            try container.encode(LocationOption.communityChest, forKey: .locationOption)
            
        case .chance:
            try container.encode(LocationOption.chance, forKey: .locationOption)
            
        case .jail:
            try container.encode(LocationOption.jail, forKey: .locationOption)
            
        case .goToJail:
            try container.encode(LocationOption.goToJail, forKey: .locationOption)
            
        case let .incomeTax(name, fee):
            try container.encode(LocationOption.incomeTax, forKey: .locationOption)
            try container.encode(fee, forKey: .fee)
            try container.encode(name, forKey: .name)
        
        case let .go(fee: fee):
            try container.encode(LocationOption.go, forKey: .locationOption)
            try container.encode(fee, forKey: .fee)
        
        case let .warehouse(name: name, purchasePrice: purchasePrice, rent: rent):
            try container.encode(LocationOption.warehouse, forKey: .locationOption)
            try container.encode(name, forKey: .name)
            try container.encode(purchasePrice, forKey: .purchasePrice)
            try container.encode(rent, forKey: .rent)
        
        case let .retail(name: name, purchasePrice: purchasePrice, rent: rent, upgradePrice: upgradePrice):
            try container.encode(LocationOption.retail, forKey: .locationOption)
            try container.encode(name, forKey: .name)
            try container.encode(purchasePrice, forKey: .purchasePrice)
            try container.encode(rent, forKey: .rent)
            try container.encode(upgradePrice, forKey: .upgradePrice)
        }
    }
}
