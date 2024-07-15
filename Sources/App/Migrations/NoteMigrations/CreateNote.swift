//
//  CreateNote.swift
//
//
//  Created by Darshan S on 11/05/24.
//

import Foundation
import Fluent

struct CreateNote: AppMigration {
    
    typealias MigraterModelClass = Note
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(MigraterModelClass.schema)
            .id()
            .field(MigraterModelClass.note, .string, .required)
            .field(MigraterModelClass.cardColor, .string, .required)
            .field(MigraterModelClass.date, .date, .required)
            .field(MigraterModelClass.userId,.uuid,.required,.references(User.schema, .id))
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(MigraterModelClass.schema).delete()
    }
}

