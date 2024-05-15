//
//  AppMigration.swift
//
//
//  Created by Darshan S on 15/05/24.
//

import Vapor
import Fluent

public protocol AppMigration: Migration {
    
    associatedtype MigraterModelClass: Modelable
    
}
