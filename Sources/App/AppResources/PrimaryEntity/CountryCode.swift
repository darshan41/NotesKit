//
//  CountryCode.swift
//
//
//  Created by Darshan S on 15/07/24.
//

import Foundation
import Vapor

public struct CountryCode: Hashable, Equatable, CustomStringConvertible, Sendable, Codable {
    
    public let code: String
    
    public init(code: String) throws {
        guard CountryCode.isValidCountryCode(code) else {
            throw CustomCountryCodeError.invalidCountryCodeFormat as ErrorShowable
        }
        self.code = code
    }
    
    public init?(_ code: String) {
        try? self.init(code: code)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        try self.init(code: try container.decode(String.self))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(code)
    }
}

public extension CountryCode {
    
    var description: String {
        code
    }
    
    static func isValidCountryCode(_ code: String) -> Bool {
        let codeRegex = "^[0-9]{1,3}$" // Matches 1 to 3 digits
        let codePredicate = NSPredicate(format: "SELF MATCHES %@", codeRegex)
        return codePredicate.evaluate(with: code)
    }
}

// MARK: Helper func's

private extension CountryCode {
    
    var isValid: Bool {
        return CountryCode.isValidCountryCode(code)
    }
    
    enum CodingKeys: String, CodingKey {
        case code
    }
    
    static func decode(from codeString: String) throws -> CountryCode {
        try CountryCode(code: codeString)
    }
}

extension CountryCode {
    
    public static func == (lhs: CountryCode, rhs: CountryCode) -> Bool {
        lhs.code == rhs.code
    }
}

extension CountryCode {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(code)
    }
}

extension CountryCode {
    
    public enum CustomCountryCodeError: ErrorShowable {
        
        public var isUserShowableErrorMessage: Bool { true }
        
        public var identifier: String {
            return "\(Self.self)"
        }
        
        public var reason: String {
            switch self {
            case .invalidCountryCodeFormat:
                return "The Country Code Format is Invalid. Please provide a valid numeric country code."
            }
        }
        
        case invalidCountryCodeFormat
    }
}
