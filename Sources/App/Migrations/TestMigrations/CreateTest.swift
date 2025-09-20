//
//  CreateTest.swift
//  NotesKit
//
//  Created by Darshan S on 20/09/25.
//

import Foundation
import Fluent

struct CreateTest: AppMigration {
    
    typealias MigraterModelClass = QueryRun
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(MigraterModelClass.schema)
            .id()
            .field(MigraterModelClass.query, .string, .required)
            .field(MigraterModelClass.safe, .bool, .required)
            .field(MigraterModelClass.createdDate, .date, .required)
            .field(MigraterModelClass.updatedDate, .date, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(MigraterModelClass.schema).delete()
    }
}


