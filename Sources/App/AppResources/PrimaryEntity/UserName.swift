//
//  UserName.swift
//
//
//  Created by Darshan S on 15/07/24.
//

import Foundation

public struct UserName: Hashable, Equatable, CustomStringConvertible, Sendable, Codable {
    
    public let username: String
    
    public init(username: String) throws {
        guard UserName.isValidUserName(username) else {
            throw CustomUserNameError.invalidUsernameFormat as ErrorShowable
        }
        self.username = username
    }
    
    public init?(_ username: String) {
        try? self.init(username: username)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        try self.init(username: try container.decode(String.self))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(username)
    }
}

public extension UserName {
    
    var description: String { username }
    
    static func isValidUserName(_ username: String) -> Bool {
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let usernameRegex = "^[a-zA-Z0-9_]{4,16}$"
        let usernamePredicate = NSPredicate(format: "SELF MATCHES %@", usernameRegex)
        return usernamePredicate.evaluate(with: trimmedUsername)
    }

}

// MARK: Helper func's

private extension UserName {
    
    var isValid: Bool {
        return UserName.isValidUserName(username)
    }
    
    enum CodingKeys: String, CodingKey {
        case username
    }
    
    static func decode(from usernameString: String) throws -> UserName {
        try UserName(username: usernameString)
    }
}

extension UserName {
    
    public static func == (lhs: UserName, rhs: UserName) -> Bool {
        lhs.username == rhs.username
    }
}

extension UserName {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(username)
    }
}

extension UserName {
    
    public enum CustomUserNameError: ErrorShowable {
        
        public var isUserShowableErrorMessage: Bool { true }
        
        public var identifier: String {
            return "\(Self.self)"
        }
        
        public var reason: String {
            switch self {
            case .invalidUsernameFormat:
                return "The Username Format is Invalid. Please provide a username between 4 to 16 characters long, consisting of alphanumeric characters and underscores."
            }
        }
        
        case invalidUsernameFormat
    }
}
