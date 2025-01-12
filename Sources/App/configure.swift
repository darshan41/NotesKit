import Vapor
import Fluent
import Leaf

public func configure(_ app: Application) async throws {
    app.views.use(.leaf)
    try await AppDB.configureAppRunningPostgress(app)
}
