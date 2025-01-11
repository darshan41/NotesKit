//
//  Migrator.swift
//
//
//  Created by Darshan S on 15/05/24.
//

import Vapor
import Fluent

public class AppMigrator: @unchecked Sendable {
    
    private let app: Application
    private(set)var migrators: [any AppMigration] = []
    
    public init(app: Application) {
        self.app = app
    }
    
    public func append(_ migration: any AppMigration) {
        self.migrators.append(migration)
        self.app.migrations.add(migration)
    }
    
    public func append(_ migrations: any AppMigration...) {
        self.migrators.append(contentsOf: migrations)
        self.app.migrations.add(migrations)
    }
    
    public func append(_ migrations: [any AppMigration]) {
        self.migrators.append(contentsOf: migrations)
        self.app.migrations.add(migrations)
    }
}

