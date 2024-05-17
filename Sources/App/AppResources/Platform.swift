//
//  Platform.swift
//
//
//  Created by Darshan S on 17/05/24.
//

import Foundation
import Vapor
import Fluent

open class Platform {
    
    func clientSupportedVersion(for platform: Platform.SupportedPlatform,api version: APIVersion) -> ClientVersion {
        ClientVersion.init(with: platform)
    }
}

public extension Platform {
    
    enum SupportedPlatform: String,Codable {
        case iOS,android
    }
    
}
