import Foundation

public struct Player: Codable, Equatable {
    static let maxNameLength = 30
    
    enum Errors: Error {
        case nameTooLong
        case blankName
    }
    
    public let name: String
    
    public init(name: String) throws {
        self.name = name
        try validateName(name)
    }
    
    private func validateName(_ name: String) throws {
        if name.isEmpty { throw Errors.blankName }
        if name.count > Player.maxNameLength { throw Errors.nameTooLong }
    }
}
