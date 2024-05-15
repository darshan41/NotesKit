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
        database.schema(Profile.schema)
            .id()
            .field(Profile.profileImage, .string, .required)
            .field(Profile.profileName, .string, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Profile.schema).delete()
    }
}


