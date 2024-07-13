//
//  GenericUsersController.swift
//
//
//  Created by Darshan S on 15/05/24.
//

import Vapor
import Fluent

class GenericUsersController<T: SortableItem, U: FieldProperty<T, T.FilteringValue>>: GenericItemController<T> where T.FilteringValue == U.Value {
    
    private let userID: String = "userID"
    
    override init(
        app: Application,
        version: APIVersion,
        decoder: JSONDecoder = AppDecoder.shared.iso8601JSONDeocoder
    ) {
        super.init(app: app, version: version, decoder: decoder)
    }
    
    override func boot(routes: any RoutesBuilder) throws {
        try super.boot(routes: routes)
    }
    
    override func generateUnableToFind(forRequested id: T.IDValue) -> String {
        "Unable to find the user for requested id: \(id)"
    }
    
    override func apiPathComponent() -> [PathComponent] {
        super.apiPathComponent() + [.constant(User.schema)]
    }
    
    override func finalComponents() -> [PathComponent] {
        apiPathComponent() + pathVariableComponents()
    }
    
    override func pathVariableComponents() -> [PathComponent] {
        [.parameter(.id)]
    }
}

