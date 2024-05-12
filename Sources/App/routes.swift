import Vapor

func routes(_ app: Application) throws {
    let router = Router<Note>(app: app)
    router.postCreateNote()
}
