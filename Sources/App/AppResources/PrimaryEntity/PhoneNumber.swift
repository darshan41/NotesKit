//
//  PhoneNumber.swift
//
//
//  Created by Darshan S on 15/07/24.
//

import Foundation

public struct PhoneNumber: Hashable, Equatable, CustomStringConvertible, Sendable, Codable {
    
    public let phone: String
    
    public init(phone: String) throws {
        guard PhoneNumber.isValidPhoneNumber(phone) else {
            throw CustomPhoneNumberError.invalidPhoneNumberFormat as ErrorShowable
        }
        self.phone = phone
    }
    
    public init?(_ number: String) {
        try? self.init(phone: number)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        try self.init(phone: try container.decode(String.self))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(phone)
    }
}

public extension PhoneNumber {
    
    var description: String { phone }
    
    static func isValidPhoneNumber(_ number: String) -> Bool {
        let phoneRegex = "^[0-9]{5,15}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: number)
    }
}

// MARK: Helper func's

private extension PhoneNumber {
    
    var isValid: Bool { PhoneNumber.isValidPhoneNumber(phone) }
    
    enum CodingKeys: String, CodingKey {
        case phone
    }
    
    static func decode(from numberString: String) throws -> PhoneNumber {
        try PhoneNumber(phone: numberString)
    }
}

extension PhoneNumber {
    
    public static func == (lhs: PhoneNumber, rhs: PhoneNumber) -> Bool {
        lhs.phone == rhs.phone
    }
}

extension PhoneNumber {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(phone)
    }
}

extension PhoneNumber {
    
    public enum CustomPhoneNumberError: ErrorShowable {
        
        public var isUserShowableErrorMessage: Bool { true }
        
        public var identifier: String {
            return "\(Self.self)"
        }
        
        public var reason: String {
            switch self {
            case .invalidPhoneNumberFormat:
                return "The Phone Number Format is Invalid. Please provide a valid numeric phone number."
            }
        }
        
        case invalidPhoneNumberFormat
    }
}
