//
//  CreateNoteCategoryPivot.swift
//
//
//  Created by Darshan S on 20/07/24.
//

import Fluent

struct CreateNoteCategoryPivot: AppMigration {
    
    typealias MigraterModelClass = NoteCategoryPivot
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(MigraterModelClass.schema)
            .id()
            .field(MigraterModelClass.noteID, .uuid, .required,.references(Note.schema, .id,onDelete: .cascade))
            .field(MigraterModelClass.categoryID, .uuid, .required,.references(Category.schema, .id,onDelete: .cascade))
            .field(MigraterModelClass.createdDate, .date, .required)
            .field(MigraterModelClass.updatedDate, .date, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(MigraterModelClass.schema).delete()
    }
}
