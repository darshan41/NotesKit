//
//  CreateUser.swift
//
//
//  Created by Darshan S on 15/05/24.
//

import Foundation
import Fluent

struct CreateUser: AppMigration {
    
    typealias MigraterModelClass = User
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(User.schema)
            .id()
            .field(User.name, .string, .required)
            .field(User.email, .string, .required)
            .field(User.userName, .string, .required)
            .field(User.zipcode, .string, .required)
            .field(User.countryCode, .string, .required)
            .field(User.phone, .string, .required)
            .field(User.createdDate, .date, .required)
            .field(User.updatedDate, .date, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(User.schema).delete()
    }
}


