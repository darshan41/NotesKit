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
        database.schema(MigraterModelClass.schema)
            .id()
            .field(MigraterModelClass.name, .string, .required)
            .field(MigraterModelClass.email, .string, .required)
            .field(MigraterModelClass.userName, .string, .required)
            .field(MigraterModelClass.zipcode, .string, .required)
            .field(MigraterModelClass.countryCode, .string, .required)
            .field(MigraterModelClass.phone, .string, .required)
            .field(MigraterModelClass.createdDate, .date, .required)
            .field(MigraterModelClass.updatedDate, .date, .required)
            .unique(on: MigraterModelClass.email, name: MigraterModelClass.email.description)
            .unique(on: MigraterModelClass.phone, name: MigraterModelClass.phone.description)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(MigraterModelClass.schema).delete()
    }
}


