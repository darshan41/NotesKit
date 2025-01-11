//
//  AppError.swift
//
//
//  Created by Darshan S on 16/05/24.
//

import Vapor

public struct ErrorMessage: DebuggableError, Codable, Sendable {
    
    public static let inDebugMode = _isDebugAssertConfiguration()

    public var identifier: String { self.value.identifier }
    public var reason: String { self.value.reason }
    public var value: AppError
    public var appErrorSource: ErrorSource
    
    public var debugErrorDescription: String { self.appErrorSource.errorCodeStatement }
    
    public init(
        _ value: AppError,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        column: UInt = #column,
        range: Range<UInt>? = nil
    ) {
        self.value = value
        self.appErrorSource = .init(
            file: file,
            function: function,
            line: line,
            column: column,
            range: range
        )
    }
}

// MARK: public Helper func's

public extension ErrorMessage {
    
    enum AppError: ErrorShowable {
                
        static let useSorting: Bool = true
        
        public var identifier: String {
            switch self {
            case .customError(let errorShowable):
                return errorShowable.identifier
            default:
                return "\(Self.self)"
            }
        }
        
        public var isUserShowableErrorMessage: Bool {
            switch self {
            case .customError(let errorShowable):
                return errorShowable.isUserShowableErrorMessage
            default:
                return false
            }
        }
        
        public var reason: String {
            switch self {
            case .custom(let customStringError):
                return customStringError
            case .customErrors(let errorDict):
                if AppError.useSorting {
                    return errorDict.sortedOnKeysJoinedTogetherByValue.joined(separator: "/n")
                } else {
                    return errorDict.stringifiedJoinedByLineBreakSeperator
                }
            case .customArrayError(let array):
                return array.joined(separator: "/n")
            case .customError(let errorShowable):
                return errorShowable.reason
            }
        }
        
        case customError(ErrorShowable)
        case custom(String)
        case customErrors([String: String])
        case customArrayError([String])
    }

}

// MARK: ErrorMessage.AppError Codable Support

public extension ErrorMessage.AppError {
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(reason)
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let stringContent = try? container.decode(String.self) {
            self = .custom(stringContent)
        } else if let dictContent = try? container.decode([String: String].self) {
            self = .customErrors(dictContent)
        } else {
            self = .customArrayError(try container.decode([String].self))
        }
    }
}

public extension ErrorSource  {
    
    var errorCodeStatement: String {
        return """
at file: \(file),
function Named: \(function),
in line: \(line),
at column: \(column),/n
Lower Bound: \(String(range?.lowerBound ?? 1))
Upper Bound: \(String(range?.upperBound ?? 1))
"""
}
}

// MARK: ErrorMessage Codable Support

public extension ErrorMessage {
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        if ErrorMessage.inDebugMode {
            try container.encode(EncodeWrapper(
                debugErrorDescription: appErrorSource.errorCodeStatement,
                error: reason,
                identifier: identifier
            ))
        } else {
            try container.encode(reason)
        }
    }
    
    static func customString(
        _ singleErrorString: String,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        column: UInt = #column,
        range: Range<UInt>? = nil
    ) -> ErrorMessage {
        ErrorMessage.init(
            .custom(singleErrorString),
                file: file,
                function: function,
                line: line,
                column: column,
                range: range
        )
    }
    
    static func customString(
        _ error: Error,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        column: UInt = #column,
        range: Range<UInt>? = nil
    ) -> ErrorMessage {
        if ErrorMessage.inDebugMode {
            return ErrorMessage.init(
                .customError(error.asErrorShowble),
                file: file,
                function: function,
                line: line,
                column: column,
                range: range
            )
        } else {
            return ErrorMessage.init(
                .customError(error.asErrorShowble),
                file: file,
                function: function,
                line: line,
                column: column,
                range: range
            )
        }
    }
    
    static func customErrors(
        _ errorDictionary: [String : String],
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        column: UInt = #column,
        range: Range<UInt>? = nil
    ) -> ErrorMessage {
        ErrorMessage.init(
            .customErrors(errorDictionary),
            file: file,
            function: function,
            line: line,
            column: column,
            range: range
        )
    }
    
    static func customArray(
        _ errorArray: [String],
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        column: UInt = #column,
        range: Range<UInt>? = nil
    ) -> ErrorMessage {
        ErrorMessage.init(
            .customArrayError(errorArray),
            file: file,
            function: function,
            line: line,
            column: column,
            range: range
        )
    }
}

extension ErrorSource: Codable {
    
    public enum CodingKeys: String,CodingKey {
        case file
        case function
        case line
        case column
        case range
        case lowerBound
        case upperBound
    }
    
    public init(from decoder: any Decoder) throws {
        self.init(file: #file, function: #function, line: #line, column: #column)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        file = try container.decode(String.self, forKey: .file)
        function = try container.decode(String.self, forKey: .function)
        line = try container.decode(UInt.self, forKey: .line)
        column = try container.decode(UInt.self, forKey: .column)
        range = nil
        if let lowerBound = try? container.decode(UInt.self, forKey: .lowerBound),let upperBound = try? container.decode(UInt.self, forKey: .upperBound),lowerBound < upperBound {
            range = .init((lowerBound...upperBound))
        } else {
            range = nil
        }
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.errorCodeStatement)
    }
}

fileprivate struct EncodeWrapper: Codable {
    
    let debugErrorDescription: String
    let error: String
    let identifier: String
}

extension Error {
    
    var asErrorShowble: ErrorShowable {
        if ErrorMessage.inDebugMode {
            let detailedDescription: String = "localizedDescription: \(self.localizedDescription) \n other description: \((self as NSError).description)"
            return (self as? ErrorShowable) ?? ErrorMessage.AppError.custom(detailedDescription)
        } else {
            return (self as? ErrorShowable) ?? ErrorMessage.AppError.custom("Something Went Wrong!")
        }
    }
}
