public struct Dice: Codable {
    private let numberOfSides: UInt32
    
    public init(numberOfSides: UInt32) {
        self.numberOfSides = numberOfSides
    }
    
    public func roll() -> Int {
        return Int(arc4random_uniform(numberOfSides) + 1)
    }
}
