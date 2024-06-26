//
//  GenericRootController.swift
//
//
//  Created by Darshan S on 21/06/24.
//

import Vapor
import Fluent

open class GenericRootController<T: Notable>: @unchecked Sendable,VersionedRouteCollection {
    
    private (set)var decoder: JSONDecoder
    
    private (set)var app: Application
    private (set)open var version: APIVersion
  
    init(
        app: Application,
        version: APIVersion,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.app = app
        self.version = version
        self.decoder = decoder
    }
    
    open func boot(routes: any Vapor.RoutesBuilder) throws { }
    
    open func generateUnableToFind(forRequested id: T.IDValue) -> String {
        "Unable to find the item for requested id: \(id)"
    }
    
    /// By Default All POST and Get use this.... as last path.
    /// - Returns: PathComponent
    /// eg: http://127.0.0.1:8080/api/v1/note
    func apiPathComponent() -> [PathComponent] {
        version.apiPath
    }
    
    /// The Query Components for DELETE,GET(with id) or Put
    /// - Returns: PathComponent
    /// eg: http://127.0.0.1:8080/api/v1/note/:id
    func pathVariableComponents() -> [PathComponent] {
        return []
    }
    
    /// Combines the apiPathComponent() and pathVariableComponents() to build, use overides carefully.
    /// - Returns: PathComponent
    func finalComponents() -> [PathComponent] {
        apiPathComponent() + pathVariableComponents()
    }
     
    func generateUnableToPerformOperationOnQuery(forRequested fieldValue: String) -> String {
        var param = fieldValue
        if let firstChar = param.first {
            param.replaceSubrange(param.startIndex..<param.index(after: param.startIndex), with: String(firstChar).capitalized)
        }
        return "\(param) Value not present to filter, must have \(fieldValue) Field."
    }
}
