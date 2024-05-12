//
//  APIVersion1.swift
//
//
//  Created by Darshan S on 12/05/24.
//

import Fluent
import Vapor

final class APIVersion1: APIVersion {
    
    override var version: String { "v1" }
    
    override var apiPath: [PathComponent] { [.constant(super.api),.constant(self.version)] }
}
