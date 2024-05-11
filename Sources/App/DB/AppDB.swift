//
//  AppDB.swift
//
//
//  Created by Darshan S on 11/05/24.
//

import Vapor
import FluentKit
import FluentPostgresDriver

public class AppDB {
    
    public class func configureAppRunningPostgress(_ app: Application) async throws {
        app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
            hostname: Environment.get("DATABASE_HOST") ?? "localhost",
            port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
            username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
            password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
            database: Environment.get("DATABASE_NAME") ?? "vapor_database",
            tls: .prefer(try .init(configuration: .clientDefault)))
        ), as: .psql)
        
        app.migrations.add(CreateNote())
        app.logger.logLevel = .debug
        try app.autoMigrate().wait()
        try routes(app)
    }
}
