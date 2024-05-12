//
//  EventLoopFuture.swift
//
//
//  Created by Darshan S on 12/05/24.
//

import Fluent
import Vapor

extension EventLoopFuture where Value: Notable {
    
    var customResponse: EventLoopFuture<AppResponse<Value>> {
        map { AppResponse(code: .ok, error: nil, data: $0) }
    }
}


