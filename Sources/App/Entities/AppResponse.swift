//
//  File.swift
//  
//
//  Created by Darshan S on 12/05/24.
//

import Foundation
import Fluent
import Vapor

public protocol CodedStringable: Codable {
    
    var stringifiedValue: String { get }
}

public enum ErrorMessage: CodedStringable, Error {
    
    static let useSorting: Bool = true
    
    public var stringifiedValue: String {
        switch self {
        case .customString(let string):
            return string
        case .errorMessages(let dictionary):
            if ErrorMessage.useSorting {
                return dictionary.sortedOnKeysJoinedTogetherByValue.joined(separator: "\n")
            } else {
                return dictionary.stringifiedJoinedByLineBreakSeperator
            }
        }
    }
    
    case customString(String)
    case errorMessages([String: String])
}

public protocol NoteResponseEncodable {
    
    associatedtype T: Content
    var data: T? { get }
}

public struct AppResponse<T: Content>: ResponseEncodable,NoteResponseEncodable,Content {
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: AppResponse<T>.CodingKeys.self)
        try container.encode(self.code, forKey: .code)
        let error = self.error?.stringifiedValue
        try container.encodeIfPresent(error, forKey: .error)
        try container.encodeIfPresent(self.data, forKey: .data)
        if error != nil {
            try container.encodeIfPresent(self.isUserShowableErrorMessage || error == nil, forKey: .isUserShowableErrorMessage)
        }
    }
    
    public func encodeResponse(for request: Vapor.Request) -> NIOCore.EventLoopFuture<Vapor.Response> {
        do {
            let response = Response(status: self.code)
            try response.content.encode(self)
            return request.eventLoop.future(response)
        } catch let error {
            return request.eventLoop.future(error: error)
        }
    }
    
    public let code: HTTPResponseStatus
    public let error: ErrorMessage?
    public let data: T?
    public private (set)var isUserShowableErrorMessage: Bool = false
    
    public mutating func settingAsUserErrorShowable() {
        isUserShowableErrorMessage = true
    }
}

// MARK: Helper func's

extension NoteResponseEncodable {
    
    public var encodeData: T {
        get throws {
            guard let data else {
                throw ErrorMessage.customString("Server Error, Unable to encode data this was not supposed to happen!")
            }
            return data
        }
    }
}

extension Dictionary<String,String> {
    
    var intified: [Dictionary<Int, String>.Element] {
        self.compactMap { dict -> Dictionary<Int,String>.Element? in
            guard let intified = Int(dict.key) else { return nil }
            return Dictionary<Int,String>.Element(key: intified, value: dict.value)
        }
    }
    
    var sortedOnKeys: [Dictionary<String, String>.Element] {
        self.sorted(by: { $0.key < $1.key })
    }
    
    var stringifiedJoinedByLineBreakSeperator: String {
        map({ $0.key + " " + $0.value }).joined(separator: "\n")
    }
    
    var sortedOnKeysJoinedTogetherByValue: [String] {
        sortedOnKeys.map { $0.key + " " + $0.value }
    }
}

extension Array where Element == Dictionary<Int,String>.Element {
    
    var intiSorted: [Dictionary<Int, String>.Element] {
        sorted(by: { $0.key < $1.key })
    }
}
