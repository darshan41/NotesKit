//
//  File.swift
//  
//
//  Created by Darshan S on 12/05/24.
//

import Foundation
import Fluent
import Vapor

public enum ErrorMessage: Codable, Error {
    case customString(String)
    case errorMessages([String: String])
}

public protocol NoteResponseEncodable {
    
    associatedtype T: Content
    var data: T? { get }
}

public struct AppResponse<T: Content>: ResponseEncodable,NoteResponseEncodable,Content {
    
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
