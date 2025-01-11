//
//  ClientVersion.swift
//
//
//  Created by Darshan S on 17/05/24.
//


import Vapor
import Fluent

open class ClientVersion {
    
    public private(set)var supportedPlatform: Platform.SupportedPlatform
    
    public init(with supportedPlatform: Platform.SupportedPlatform) {
        self.supportedPlatform = supportedPlatform
    }
}
