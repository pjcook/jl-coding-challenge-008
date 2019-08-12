import Shopopoly

enum Monopoly {
    static let startingCapital: Money = 1500
    
    static let dice = [Dice(numberOfSides: 6), Dice(numberOfSides: 6)]
    
    static let locations: [Location] = [
        .go(fee: 200),
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
