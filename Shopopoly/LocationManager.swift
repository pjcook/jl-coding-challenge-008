import Foundation

struct LocationManager: Codable {
    private let locations: [Location]
    private let locationData: [LocationData]
    
    func canPurchase(_ index: Int) -> Bool {
        guard (0..<locationData.count).contains(index) else { return false }
        return locationData[index].canPurchase
    }
    
    func passingFee(_ location: Location) -> Double {
        switch location {
        case .freeParking: return 0
        case let .go(fee: fee):
            return fee
        case .warehouse: return 0
        case .retail: return 0
        }
    }
}
