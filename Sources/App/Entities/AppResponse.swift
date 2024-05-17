//
//  File.swift
//  
//
//  Created by Darshan S on 12/05/24.
//

import Foundation
import Fluent
import Vapor

public protocol NoteResponseEncodable {
    
    associatedtype T: Content
    var data: T? { get }
}

public struct AppResponse<T: Content>: ResponseEncodable,NoteResponseEncodable,Content {
    
    public enum CodingKeys: String,CodingKey {
        case code
        case error
        case data
        case isServerGeneratedError
        case isUserShowableErrorMessage
        case identifier
        case debugErrorDescription
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: AppResponse<T>.CodingKeys.self)
        try container.encode(self.code, forKey: .code)
        try container.encodeIfPresent(error?.reason, forKey: .error)
        try container.encodeIfPresent(error?.identifier, forKey: .identifier)
        try container.encodeIfPresent(error?.debugErrorDescription, forKey: .debugErrorDescription)
        try container.encodeIfPresent(self.data, forKey: .data)
        if error != nil {
            try container.encode(self.isServerGeneratedError, forKey: .isServerGeneratedError)
            try container.encode(self.isUserShowableErrorMessage, forKey: .isUserShowableErrorMessage)
        }
    }
    
    public func encodeResponse(for request: Vapor.Request) -> NIOCore.EventLoopFuture<Vapor.Response> {
        do {
            let response = Response(status: self.code)
            try response.content.encode(self)
            return request.eventLoop.future(response)
        } catch let error {
            return request.eventLoop.future(error: ErrorMessage.customString(error))
        }
    }
    
    public let code: HTTPResponseStatus
    public let error: ErrorMessage?
    public let data: T?
    public private (set)var isServerGeneratedError: Bool = false
    public private (set)var isUserShowableErrorMessage: Bool = false
    private var identifier: String? = nil
    private var debugErrorDescription: String? = nil
    
    public init(
        code: HTTPResponseStatus,
        error: ErrorMessage?,
        data: T?,
        isServerGeneratedError: Bool = false
    ) {
        self.code = code
        self.error = error
        self.data = data
        self.isServerGeneratedError = isServerGeneratedError
        self.isUserShowableErrorMessage = (error?.value.isUserShowableErrorMessage ?? false)
        self.identifier = nil
        self.debugErrorDescription = nil
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

