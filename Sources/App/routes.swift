import Vapor

func routes(_ app: Application) throws {
    let router = Router<Note>(app: app)
    router.postCreateNote()
    router.getSpecificHavingIDNote()
    router.getNote()
    router.putTheNote()
    router.deleteTheNote()
}
