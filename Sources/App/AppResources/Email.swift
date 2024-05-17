//
//  Email.swift
//
//
//  Created by Darshan S on 15/05/24.
//

import Foundation

public struct Email: Hashable, Equatable, CustomStringConvertible, Sendable, Codable {
    
    public let prefix: String
    public let domain: String
    
    init(prefix: String, domain: String) {
        self.prefix = prefix
        self.domain = domain
    }
    
    public init(emailString: String) throws {
        guard let atIndex = emailString.firstIndex(of: "@") else {
            throw CustomEmailError.invalidEmailFormat as ErrorShowable
        }
        let prefixSubstring = emailString.prefix(upTo: atIndex)
        let domainSubstring = emailString.suffix(from: emailString.index(after: atIndex))
        self.prefix =  String(prefixSubstring)
        self.domain = String(domainSubstring)
    }
    
    public init?(_ emailString: String) {
        try? self.init(emailString: emailString)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        try self.init(emailString: try container.decode(String.self))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(emailString)
    }
}

public extension Email {
    
    var emailString: String {
        "\(prefix)@\(domain)"
    }
    
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    var description: String {
        generate()
    }
}

// MARK: Helper func's

private extension Email {
    
    var isValid: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: "\(prefix)@\(domain)")
    }
    
    func generate() -> String {
        let randomString = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        return "\(prefix)\(randomString)@\(domain)"
    }
    
    enum CodingKeys: String, CodingKey {
        case prefix
        case domain
    }
    
    static func decode(from emailString: String) throws -> Email {
        try Email(emailString: emailString)
    }
}

extension Email {
    
    public static func == (lhs: Email, rhs: Email) -> Bool {
        lhs.prefix == rhs.prefix && lhs.domain == rhs.domain
    }
}

extension Email {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(prefix)
        hasher.combine(domain)
    }
}

extension Email {
    
    public enum CustomEmailError: ErrorShowable {
        
        public var isUserShowableErrorMessage: Bool { true }
        
        public var identifier: String {
            return "\(Self.self)"
        }
        
        public var reason: String {
            switch self {
            case .invalidEmailFormat:
                "The Email Format is Invalid Please provide proper email as per Standards"
            }
        }
        
        case invalidEmailFormat
    }
}
