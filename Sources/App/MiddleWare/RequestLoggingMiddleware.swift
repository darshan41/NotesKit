//
//  RequestLoggingMiddleware.swift
//
//
//  Created by Darshan S on 13/05/24.
//

import Foundation
import Vapor

final class RequestLoggingMiddleware: Middleware {
    
    #if DEBUG
    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        let url = request.url
        print("Request URL: \(url)")
        let urlComponents = request.url        
        let path = urlComponents.path
        let query = urlComponents.query ?? ""
        print("Path: \(path)")
        print("Query: \(query)")
        
        // Continue processing the request
        return next.respond(to: request)
    }
    #endif
}
