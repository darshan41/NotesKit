//
//  GenericRootController.swift
//
//
//  Created by Darshan S on 21/06/24.
//

import Vapor
import Fluent

class GenericRootController<T: Notable>: @unchecked Sendable {
    
    private(set)var decoder: JSONDecoder
    
    private(set)var app: Application
    private(set)open var version: APIVersion
    private(set)open var manager: ApplicationManager
    
    init<Manager: ApplicationManager>(
        kit: Manager,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.app = kit.app
        self.version = kit.apiVersion
        self.decoder = decoder
        self.manager = kit
    }
        
    open func generateUnableToFind(forRequested id: T.IDValue) -> String {
        "Unable to find the \(T.objectTitleForErrorTitle) for requested id: \(id)"
    }
    
    open func generateUnableToFindAny(forRequested type: T.Type,for method: HTTPMethod) -> String {
        "ID for path to \(method.rawValue.lowercased()) for an \(type) item must be present, eg: type/{\(type.objectIdentifierKey)} item.}"
    }
    
    open func generateUnableToFindAny(forRequested id: UUID,for method: HTTPMethod) -> String {
        "ID for path to \(method.rawValue.lowercased()) for an \(id) item must be present, eg: type/{particular-id-for-\(String.init(describing: id).lowercased())item.} "
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
