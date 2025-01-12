import Vapor
import Logging

@main
enum Entrypoint {
    static func main() async throws {
        var env = try Environment.detect()
        try LoggingSystem.bootstrap(from: &env)
        let app = try await Application.make(env)
        defer {
            Task {
                do {
                    try await app.asyncShutdown()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        
        do {
            try await configure(app)
//            try await app.autoRevert().wait()
//            try await app.autoMigrate().wait()
        } catch {
            app.logger.report(error: error)
            throw error
        }
        try await app.execute()
    }
}
