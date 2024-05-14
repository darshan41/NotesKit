import Vapor
import FluentKit

func routes(_ app: Application) throws {
    let router = NotesRouterController<Note,FieldProperty<Note, Note.FilteringValue>>(app: app, version: APIVersion1())
    try app.register(collection: router)
}
