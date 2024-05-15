//
//  ProfilesController.swift
//
//
//  Created by Darshan S on 15/05/24.
//

import Vapor
import Fluent

class ProfilesController<T: SortableItem, U: FieldProperty<T, T.FilteringValue>>: GenericItemController<T> where T.FilteringValue == U.Value {
    
    private let profileID: String = "profileID"
    
    override init(
        app: Application,
        version: APIVersion,
        decoder: JSONDecoder = AppDecoder.shared.iso8601JSONDeocoder
    ) {
        super.init(app: app, version: version, decoder: AppDecoder.shared.iso8601JSONDeocoder)
    }
    
    override func boot(routes: any RoutesBuilder) throws {
        try super.boot(routes: routes)
    }
    
    override func generateUnableToFind(forRequested id: T.IDValue) -> String {
        "Unable to find the profile for requested id: \(id)"
    }
    
    func generateUnableToFilter(forRequested fieldValue: String) -> String {
        var param = fieldValue
        if let firstChar = param.first {
            param.replaceSubrange(param.startIndex..<param.index(after: param.startIndex), with: String(firstChar).capitalized)
        }
        return "\(param) Value not present to filter, must have \(fieldValue) Field."
    }
    
    override func apiPathComponent() -> [PathComponent] {
        super.apiPathComponent() + [.constant(Profile.schema)]
    }
    
    override func finalComponents() -> [PathComponent] {
        apiPathComponent() + pathVariableComponents()
    }
    
    override func pathVariableComponents() -> [PathComponent] {
        [.parameter(.id)]
    }
}

