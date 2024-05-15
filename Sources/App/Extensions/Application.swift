//
//  Application.swift
//
//
//  Created by Darshan S on 15/05/24.
//

import Vapor
import Fluent

public extension Application {
    
    func uses(middleware: Middleware,at position: Middlewares.Position = .end) {
        self.middleware.use(middleware, at: position)
    }
    
    func has(migration: any AppMigration) {
        self.migrations.add(migration)
    }
    
    func has(migrations: [any AppMigration]) {
        self.migrations.add(migrations)
    }
    
    func has(migrations: any AppMigration...) {
        self.migrations.add(migrations)
    }
}
