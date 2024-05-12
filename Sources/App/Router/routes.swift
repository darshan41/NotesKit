import Vapor

func routes(_ app: Application) throws {
    let router = NotesRouterController<Note>(app: app, version: APIVersion1())
    try app.register(collection: router)
}
