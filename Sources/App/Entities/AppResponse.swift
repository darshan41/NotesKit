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

public struct AppResponse<T: Content>: ResponseEncodable,NoteResponseEncodable,Content,AppResponseError {
    
    public enum CodingKeys: String,CodingKey {
        case code
        case error
        case data
        case isServerGeneratedError
        case isUserShowableErrorMessage
        case identifier
        case debugErrorDescription
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.code = try container.decode(HTTPResponseStatus.self, forKey: .code)
        self.error = try container.decodeIfPresent(ErrorMessage.self, forKey: .error)
        self.data = try container.decodeIfPresent(T.self, forKey: .data)
        self.isServerGeneratedError = (try? container.decodeIfPresent(Bool.self, forKey: .isServerGeneratedError)) ?? false
        self.isUserShowableErrorMessage = (try? container.decodeIfPresent(Bool.self, forKey: .isUserShowableErrorMessage)) ?? false
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: AppResponse<T>.CodingKeys.self)
        try container.encode(self.code, forKey: .code)
        let reason = error?.reason
        let identifier = error?.identifier
        let debugErrorDescription = error?.debugErrorDescription
        try container.encodeIfPresent(reason.isValidString ? reason : nil, forKey: .error)
        try container.encodeIfPresent(identifier.isValidString ? identifier : nil, forKey: .identifier)
        try container.encodeIfPresent(debugErrorDescription.isValidString ? debugErrorDescription : nil, forKey: .debugErrorDescription)
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
    
    public var identifier: String { error?.identifier ?? "" }
    public var reason: String { error?.reason ?? "" }
    public var debugErrorDescription: String { error?.debugErrorDescription ?? "" }
    
    
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
    }
}

extension String? {
    var isValidString: Bool { self != nil ? !self!.isEmpty : false }
}
