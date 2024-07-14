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
        database.schema(Note.schema)
            .id()
            .field(Note.note, .string, .required)
            .field(Note.cardColor, .string, .required)
            .field(Note.date, .date, .required)
            .field(Note.userId,.uuid,.required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Note.schema).delete()
    }
}

