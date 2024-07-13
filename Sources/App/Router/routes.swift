import Vapor
import FluentKit

func routes(_ app: Application) throws {
    let version = APIVersion1()
    let notesController = NotesController(app: app, version: version)
//    let usersController = GenericUsersController<User,FieldProperty<User, User.FilteringValue>>(app: app, version: version)
//    let profilesController = GenericProfilesController<Profile,FieldProperty<Profile, Profile.FilteringValue>>(app: app, version: version)
    let routeCollections: [RouteCollection] = [
        notesController,
//        usersController,
//        profilesController
    ]
    try app.controls(controllers: routeCollections)
}
