import Vapor

func routes(_ app: Application) throws {
    let router = Router(app: app)
    router.postCreateNote()
}
