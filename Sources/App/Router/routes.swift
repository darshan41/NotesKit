import Vapor
import FluentKit

func routes(_ app: Application) throws {
    let version = APIVersion1()
    let notesKit = NotesKit(app: app, apiVersion: version)
    let websiteController = WebsiteController()
    try app.register(collection: websiteController)
    try app.controls(controllers: notesKit.getAllRoutes())
}
