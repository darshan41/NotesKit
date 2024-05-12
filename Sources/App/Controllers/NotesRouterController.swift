//
//  NotesRouterController.swift
//
//
//  Created by Darshan S on 13/05/24.
//

import Vapor
import Fluent

class NotesRouterController<T: Notable>: GenericRouterController<T> {
    
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
    
    override func apiPathComponent() -> [PathComponent] {
        super.apiPathComponent() + [.constant(Note.note)]
    }
    
    override func finalComponents() -> [PathComponent] {
        apiPathComponent() + pathVariableComponents()
    }
    
    override func pathVariableComponents() -> [PathComponent] {
        [.parameter(.id)]
    }
}
