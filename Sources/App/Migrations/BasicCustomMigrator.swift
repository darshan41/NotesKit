//
//  File.swift
//  
//
//  Created by Darshan S on 14/07/24.
//

import Foundation
import Fluent

protocol BasicMigratable: Notable {
    
    var buildAddingRequiredSchema: ((SchemaBuilder) -> SchemaBuilder) { get }
}

struct BasicCustomMigrator<T: BasicMigratable>: AppMigration {
    
    private var migrator: T
    
    typealias MigraterModelClass = T
    
    init(migrator: T) {
        self.migrator = migrator
    }
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        migrator.buildAddingRequiredSchema(database.schema(T.schema)).create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(T.schema).delete()
    }
}

