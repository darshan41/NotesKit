//
//  File.swift
//  
//
//  Created by Darshan S on 12/05/24.
//

import Foundation
import Fluent
import Vapor

enum ErrorMessage: Codable, Error {
    case customString(String)
    case errorMessages([String: String])
}

protocol NoteResponseEncodable {
    
    associatedtype T: Content
    var data: T? { get }
}

struct NoteResponse<T: Content>: ResponseEncodable,NoteResponseEncodable {
    
    func encodeResponse(for request: Vapor.Request) -> NIOCore.EventLoopFuture<Vapor.Response> {
        do {
            let response = Response(status: self.code)
            try response.content.encode(try encodeData)
            return request.eventLoop.future(response)
        } catch let error {
            return request.eventLoop.future(error: error)
        }
    }
    
    let code: HTTPResponseStatus
    let error: ErrorMessage?
    let data: T?
}

extension NoteResponseEncodable {
    
    var encodeData: T {
        get throws {
            guard let data else {
                throw ErrorMessage.customString("Server Error, Unable to encode data this was not supposed to happen!")
            }
            return data
        }
    }
}
