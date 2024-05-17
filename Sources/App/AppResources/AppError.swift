//
//  AppError.swift
//
//
//  Created by Darshan S on 16/05/24.
//

import Vapor

public struct MyError: DebuggableError {
    
    public var identifier: String { self.value.identifier }
    public var reason: String { self.value.reason }
    public var value: AppError
    public var source: ErrorSource?

    public init(
        _ value: AppError,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) {
        self.value = value
        self.source = .init(
            file: file,
            function: function,
            line: line,
            column: column
        )
    }
}

public extension MyError {
    
    enum AppError: ErrorShowable,CodedStringable {
        
        static let useSorting: Bool = true
        
        public var identifier: String { "\(Self.self)" }
        
        public var reason: String { showableErrorDescription }
        
        public var showableErrorDescription: String {
            switch self {
            case .custom(let customStringError):
                return customStringError.stringifiedValue
            case .customErrors(let errorDict):
                if AppError.useSorting {
                    return errorDict.sortedOnKeysJoinedTogetherByValue.joined(separator: "\n")
                } else {
                    return errorDict.stringifiedJoinedByLineBreakSeperator
                }
            case .customArrayError(let array):
                return array.joined(separator: "\n")
            }
        }
        
        public var stringifiedValue: String { showableErrorDescription }
        
        case custom(CodedStringable)
        case customErrors([String: String])
        case customArrayError([String])
    }

}

// MARK: Codable Support

public extension MyError.AppError {
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(stringifiedValue)
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
