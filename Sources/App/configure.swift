import Vapor
import Fluent

public func configure(_ app: Application) async throws {
    try await AppDB.configureAppRunningPostgress(app)
    try routes(app)
}
