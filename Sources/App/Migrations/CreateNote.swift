//
//  CreateNote.swift
//
//
//  Created by Darshan S on 11/05/24.
//

import Foundation
import Fluent

struct CreateNote: Migration {
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Note.schema)
            .id()
            .field(.string(Note.note), .string, .required)
            .field(.string(Note.cardColor), .string, .required)
            .field(.string(Note.date), .date, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Note.schema).delete()
    }
}

