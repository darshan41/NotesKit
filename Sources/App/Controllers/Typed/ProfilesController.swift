//
//  GenericProfilesController.swift
//
//
//  Created by Darshan S on 15/05/24.
//

import Vapor
import Fluent

extension NotesKit {
    
    public class ProfilesController<T: SortableItem, U: FieldProperty<T, T.FilteringValue>>: GenericItemController<T>, @unchecked Sendable where T.FilteringValue == U.Value {
        
        private let profileID: String = "profileID"
        
        public override init<Manager: ApplicationManager>(
            kit: Manager,
            decoder: JSONDecoder = AppDecoder.shared.iso8601JSONDeocoder
        ) {
            super.init(kit: kit, decoder: decoder)
        }
        
        public override func boot(routes: any RoutesBuilder) throws {
            try super.boot(routes: routes)
        }
        
        override func apiPathComponent() -> [PathComponent] {
            super.apiPathComponent() + [.constant(T.schema)]
        }
        
        override func finalComponents() -> [PathComponent] {
            apiPathComponent() + pathVariableComponents()
        }
        
        override func pathVariableComponents() -> [PathComponent] {
            [.parameter(.id)]
        }
    }
}

