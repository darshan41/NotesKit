//
//  CreateProfile.swift
//
//
//  Created by Darshan S on 15/05/24.
//

import Vapor
import Fluent

struct CreateProfile: AppMigration {
    
    typealias MigraterModelClass = Profile
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(MigraterModelClass.schema)
            .id()
            .field(MigraterModelClass.profileImage, .string, .required)
            .field(MigraterModelClass.profileName, .string, .required)
            .field(MigraterModelClass.createdDate, .date, .required)
            .field(MigraterModelClass.updatedDate, .date, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(MigraterModelClass.schema).delete()
    }
}


