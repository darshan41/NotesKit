import Vapor
import FluentKit

func routes(_ app: Application) throws {
    let version = APIVersion1()
    let usersController = UsersController<User>(app: app, version: version)
    let notesController = NotesController(app: app, version: version)
    let profilesController = ProfilesController<Profile,FieldProperty<Profile, Profile.FilteringValue>>(app: app, version: version)
    let routeCollections: [RouteCollection] = [
        notesController,
        usersController,
        profilesController,
    ]
    try app.controls(controllers: routeCollections)
}
