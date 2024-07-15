//
//  ZipCode.swift
//
//
//  Created by Darshan S on 15/07/24.
//

import Foundation

public struct ZipCode: Hashable, Equatable, CustomStringConvertible, Sendable, Codable {
    
    public let code: String
    
    public init(code: String) throws {
        let cleanedCode = code.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        guard ZipCode.isValidZipCode(cleanedCode) else {
            throw CustomZipCodeError.invalidZipCodeFormat as ErrorShowable
        }
        self.code = cleanedCode
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

public extension ZipCode {
    
    var description: String { code }
    
    static func isValidZipCode(_ code: String) -> Bool {
        let trimmedCode = code.trimmingCharacters(in: .whitespaces)
        let zipRegex = "^[1-9][0-9]{5}$"
        let zipPredicate = NSPredicate(format: "SELF MATCHES %@", zipRegex)
        return zipPredicate.evaluate(with: trimmedCode)
    }
}

// MARK: Helper func's

private extension ZipCode {
    
    var isValid: Bool { ZipCode.isValidZipCode(code) }
    
    enum CodingKeys: String, CodingKey {
        case code
    }
    
    static func decode(from codeString: String) throws -> ZipCode {
        try ZipCode(code: codeString)
    }
}

extension ZipCode {
    
    public static func == (lhs: ZipCode, rhs: ZipCode) -> Bool {
        lhs.code == rhs.code
    }
}

extension ZipCode {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(code)
    }
}

extension ZipCode {
    
    public enum CustomZipCodeError: ErrorShowable {
        
        public var isUserShowableErrorMessage: Bool { true }
        
        public var identifier: String {
            return "\(Self.self)"
        }
        
        public var reason: String {
            switch self {
            case .invalidZipCodeFormat:
                return "The ZIP Code Format is Invalid. Please provide a valid ZIP code."
            }
        }
        
        case invalidZipCodeFormat
    }
}


