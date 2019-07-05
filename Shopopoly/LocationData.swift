import Foundation

struct LocationData: Codable {
    var owner: Player?
    var currentShop: Shop = .none
    var canBuildShop: Bool {
        switch currentShop {
        case .none, .ministore, .supermarket: return true
        case .megastore: return false
        }
    }
    var canPurchase: Bool {
        return owner == nil
    }
}
