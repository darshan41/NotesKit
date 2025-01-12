//
//  CreateCategory.swift
//
//
//  Created by Darshan S on 15/07/24.
//

import Foundation
import Fluent

struct CreateCategory: AppMigration {
    
    typealias MigraterModelClass = Category
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(MigraterModelClass.schema)
            .id()
            .field(MigraterModelClass.name, .string, .required)
            .unique(on: MigraterModelClass.name, name: MigraterModelClass.uniqueNameKey)
            .field(MigraterModelClass.createdDate, .date, .required)
            .field(MigraterModelClass.updatedDate, .date, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(MigraterModelClass.schema).delete()
    }
}


