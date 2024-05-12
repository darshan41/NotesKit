//
//  Version.swift
//
//
//  Created by Darshan S on 13/05/24.
//

import Vapor
import Fluent

public protocol Versioning { }

public protocol VersionedRouteCollection: RouteCollection {
    var version: APIVersion { get }
}

public class APIVersion {
    
    // MARK: Override this....
    
    public var version: String { "v" }
    public var api: String { "api" }
    public var apiPath: [PathComponent] { [.constant(api),.constant(version)] }
    
    public func pathComonent(with component: PathComponent...) -> [PathComponent] {
        apiPath + component
    }
}

