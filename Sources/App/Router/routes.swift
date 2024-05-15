import Vapor
import FluentKit

func routes(_ app: Application) throws {
    let version = APIVersion1()
    let notesController = NotesController<Note,FieldProperty<Note, Note.FilteringValue>>(app: app, version: version)
    let usersController = UsersController<User,FieldProperty<User, User.FilteringValue>>(app: app, version: version)
    let profilesController = ProfilesController<Profile,FieldProperty<Profile, Profile.FilteringValue>>(app: app, version: version)
    try app.controls(controllers: notesController,usersController,profilesController)
}
