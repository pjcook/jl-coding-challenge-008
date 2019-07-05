import Foundation

enum Location: Equatable {
    case freeParking
    case go(fee: Double)
    case warehouse(name: String, purchasePrice: Double, rent: Double)
    case retail(name: String, purchasePrice: Double, rent: Double, shopPurchasePrice: Double, group: RetailGroup)
}

extension Location: Codable {
    enum CodingKeys: String, CodingKey {
        case locationOption
        case fee
        case name, purchasePrice, rent, shopPurchasePrice, group
    }
    
    private enum LocationOption: String, Codable {
        case freeParking, go, warehouse, retail
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let locationOption = try container.decode(LocationOption.self, forKey: .locationOption)
        
        switch locationOption {
        case .freeParking:
            self = .freeParking
        case .go:
            let fee = try container.decode(Double.self, forKey: .fee)
            self = .go(fee: fee)
        case .warehouse:
            let name = try container.decode(String.self, forKey: .name)
            let purchasePrice = try container.decode(Double.self, forKey: .purchasePrice)
            let rent = try container.decode(Double.self, forKey: .rent)
            self = .warehouse(name: name, purchasePrice: purchasePrice, rent: rent)
        case .retail:
            let name = try container.decode(String.self, forKey: .name)
            let purchasePrice = try container.decode(Double.self, forKey: .purchasePrice)
            let rent = try container.decode(Double.self, forKey: .rent)
            let shopPurchasePrice = try container.decode(Double.self, forKey: .shopPurchasePrice)
            let group = try container.decode(RetailGroup.self, forKey: .group)
            self = .retail(name: name, purchasePrice: purchasePrice, rent: rent, shopPurchasePrice: shopPurchasePrice, group: group)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .freeParking:
            try container.encode(LocationOption.freeParking, forKey: .locationOption)
        case let .go(fee: fee):
            try container.encode(LocationOption.go, forKey: .locationOption)
            try container.encode(fee, forKey: .fee)
        case let .warehouse(name: name, purchasePrice: purchasePrice, rent: rent):
            try container.encode(LocationOption.go, forKey: .locationOption)
            try container.encode(name, forKey: .name)
            try container.encode(purchasePrice, forKey: .purchasePrice)
            try container.encode(rent, forKey: .rent)
        case let .retail(name: name, purchasePrice: purchasePrice, rent: rent, shopPurchasePrice: shopPurchasePrice, group: group):
            try container.encode(LocationOption.go, forKey: .locationOption)
            try container.encode(name, forKey: .name)
            try container.encode(purchasePrice, forKey: .purchasePrice)
            try container.encode(rent, forKey: .rent)
            try container.encode(shopPurchasePrice, forKey: .shopPurchasePrice)
            try container.encode(group, forKey: .group)
        }
    }
}
