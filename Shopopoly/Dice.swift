struct Dice: Codable {
    private let numberOfSides: UInt32
    
    init(numberOfSides: UInt32) {
        self.numberOfSides = numberOfSides
    }
    
    func roll() -> Int {
        return Int(arc4random_uniform(numberOfSides) + 1)
    }
}
