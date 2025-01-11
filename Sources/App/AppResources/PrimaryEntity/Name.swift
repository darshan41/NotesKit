//
//  Name.swift
//
//
//  Created by Darshan S on 15/07/24.
//

import Foundation

public struct Name: Hashable, Equatable, CustomStringConvertible, Sendable, Codable {
    
    public let name: String
    
    public init(name: String) throws {
        guard Name.isValidName(name) else {
            throw CustomNameError.invalidNameFormat as ErrorShowable
        }
        self.name = name
    }
    
    public init?(_ name: String) {
        try? self.init(name: name)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        try self.init(name: try container.decode(String.self))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(name)
    }
}

public extension Name {
    
    var description: String { name }
    
    static func isValidName(_ name: String) -> Bool {
        let nameRegex = "^[A-Za-z\\s-]{2,}$"
        let namePredicate = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        return namePredicate.evaluate(with: name)
    }
}

// MARK: Helper func's

private extension Name {
    
    var isValid: Bool { Name.isValidName(name) }
    
    var formatName: String {
        let nameFormatter = PersonNameComponentsFormatter()
        if let components = nameFormatter.personNameComponents(from: name) {
            return nameFormatter.string(from: components)
        } else {
            return name
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case name
    }
    
    static func decode(from nameString: String) throws -> Name {
        try Name(name: nameString)
    }
}

extension Name {
    
    public static func == (lhs: Name, rhs: Name) -> Bool {
        lhs.name == rhs.name
    }
}

extension Name {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}

extension Name {
    
    public enum CustomNameError: ErrorShowable {
        
        public var isUserShowableErrorMessage: Bool { true }
        
        public var identifier: String {
            return "\(Self.self)"
        }
        
        public var reason: String {
            switch self {
            case .invalidNameFormat:
                return "The Name Format is Invalid. Please provide a name with at least two characters."
            }
        }
        
        case invalidNameFormat
    }
}

extension Name: Comparable {
    
    public static func < (lhs: Name, rhs: Name) -> Bool {
        lhs.name < rhs.name
    }   
}
