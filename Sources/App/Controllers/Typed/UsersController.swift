//
//  GenericUsersController.swift
//
//
//  Created by Darshan S on 15/05/24.
//

import Vapor
import Fluent

public protocol RoutesGenerator {
    
    func getAllRoutes() -> [RouteCollection]
}

protocol ApplicationManager {
    var app: Application { get }
    var apiVersion: APIVersion { get }
    
    var usersController: NotesKit.UsersController { get }
    var notesController: NotesKit.NotesController { get }
    var profilesController: NotesKit.ProfilesController<Profile,FieldProperty<Profile, Profile.FilteringValue>> { get }
    var categoryController: NotesKit.CategoryController { get }
}

class NotesKit: ApplicationManager, RoutesGenerator {
    
    private(set)var app: Application
    private(set)var apiVersion: APIVersion
    
    lazy var usersController: NotesKit.UsersController = {
        NotesKit.UsersController(kit: self)
    }()
    
    lazy var notesController: NotesKit.NotesController = {
        NotesKit.NotesController(kit: self)
    }()
    
    lazy var profilesController: NotesKit.ProfilesController<Profile,FieldProperty<Profile, Profile.FilteringValue>> =  {
        NotesKit.ProfilesController<Profile,FieldProperty<Profile, Profile.FilteringValue>>(kit: self)
    }()
    
    lazy var categoryController: NotesKit.CategoryController = {
        NotesKit.CategoryController(kit: self)
    }()
    
    init(app: Application, apiVersion: APIVersion) {
        self.app = app
        self.apiVersion = apiVersion
    }
    
    func getAllRoutes() -> [any RouteCollection] {
        [
            usersController,
            notesController,
            profilesController,
            categoryController
        ]
    }
}

extension NotesKit {
    
    public class UsersController: GenericRootController<User>, VersionedRouteCollection, @unchecked Sendable {
        
        typealias NotesController = NotesKit.NotesController
        
        private let notes: String = "notes"
        
        public typealias T = User
        
        weak var notesKit: NotesKit?
        
        private let search: String = "search"
        private let queryString: String = "query"
        private let sorted: String = "sorted"
        private let sortOrder: String = "sortOrder"
        private let ascending: String = "ascending"
        private let isLikeWise: String = "isLikeWise"
        private let filter: String = "filter"
        
        public override init<Manager: ApplicationManager>(
            kit: Manager,
            decoder: JSONDecoder = AppDecoder.shared.iso8601JSONDeocoder
        ) {
            super.init(kit: kit, decoder: decoder)
        }
        
        func boot(routes: any Vapor.RoutesBuilder) throws {
            routes.add(getSpecificCodableObjectHavingID())
            routes.add(getAllCodableObjects())
            routes.add(postCreateCodableObject())
            routes.add(deleteTheCodableObject())
            routes.add(putTheCodableObject())
            routes.add(getNotesForTheUser())
        }
        
        override func apiPathComponent() -> [PathComponent] {
            super.apiPathComponent() + [.constant(T.schema)]
        }
        
        override func finalComponents() -> [PathComponent] {
            apiPathComponent() + pathVariableComponents()
        }
        
        override func pathVariableComponents() -> [PathComponent] {
            [.parameter(User.objectIdentifierKey)]
        }
    }
}

// MARK: Helper

extension NotesKit.UsersController {
    
    @discardableResult
    func postCreateCodableObject() -> Route {
        app.post(apiPathComponent(),use: postCreateCodableObjectHandler)
    }
    
    @Sendable
    func postCreateCodableObjectHandler(_ req: Request) -> EventLoopFuture<AppResponse<User.UserDTO>> {
        do {
            let user = try req.content.decode(T.self, using: self.decoder)
            return user.save(on: req.db).map {
                AppResponse<User.UserDTO>(code: .created, error: nil, data: User.UserDTO(user: user))
            }
        } catch {
            return req.eventLoop.future(AppResponse(code: .badRequest, error: .customString(error), data: nil))
        }
    }
    
    @discardableResult
    func getAllCodableObjects() -> Route {
        app.get(apiPathComponent(), use: getAllCodableObjectsHandler)
    }
    
    @discardableResult
    func getSpecificCodableObjectHavingID() -> Route {
        app.get(finalComponents(),use: getSpecificCodableObjectHavingIDHandler)
    }
    
    @Sendable
    func getSpecificCodableObjectHavingIDHandler(_ req: Request) -> NoteEventLoopFuture<T> {
        guard let idValue = req.parameters.getCastedTID(name: User.objectIdentifierKey,T.self) else {
            return req.eventLoop.future(AppResponse(code: .badRequest, error: .customString(self.generateUnableToFindAny(forRequested: T.self, for: .GET)), data: nil))
        }
        return T.find(idValue, on: req.db).flatMap { value in
            if let wrapped = value {
                return req.eventLoop.future(wrapped.successResponse())
            } else {
                return req.eventLoop.future(AppResponse<T>(code: .notFound, error: .customString(self.generateUnableToFind(forRequested: idValue)), data: nil))
            }
        }
    }
    
    @Sendable
    func getAllCodableObjectsHandler(_ req: Request)
    -> EventLoopFuture<AppResponse<[User.UserDTO]>> {
        return T.query(on: req.db).all().map { results in
            results.map({ User.UserDTO(user: $0) }).successResponse()
        }
    }
    
    @Sendable
    func getNotesForTheUserHandler(_ req: Request) -> NotesEventLoopFuture<Note> {
        guard let idValue = req.parameters.getCastedTID(name: User.objectIdentifierKey,T.self) else {
            return req.eventLoop.future(AppResponse(code: .badRequest, error: .customString(self.generateUnableToFindAny(forRequested: T.self, for: .GET)), data: nil))
        }
        let isAscending = req.query[self.sortOrder] == self.ascending
        let isLikeWise = req.query[Bool.self, at: self.isLikeWise]
        let searchTerm = req.query[String.self, at: self.queryString]
        return T.find(idValue, on: req.db)
            .unwrap(orError: AppResponse<T>(code: .notFound, error: .customString(self.generateUnableToFind(forRequested: idValue)), data: nil))
            .flatMap { user in
                let userQueryBuilder: QueryBuilder<NotesController.T> = user.$notes.query(on: req.db)
                if let searchTerm,let isLikeWise {
                    if isLikeWise {
                        userQueryBuilder.group(.or) { or in
                            or.filter(\.filterSearchItem ~~ searchTerm)
                        }
                    } else {
                        userQueryBuilder.group(.or) { or in
                            or.filter(\.filterSearchItem == searchTerm)
                        }
                    }
                }
                return userQueryBuilder.sort(\.someComparable, isAscending ? .ascending : .descending)
                    .all()
            }.mappedToSuccessResponse()
    }
    
    @Sendable
    func getSortableFilteredUsers(_ req: Request) -> NotesEventLoopFuture<Note> {
        guard let idValue = req.parameters.getCastedTID(name: User.objectIdentifierKey,T.self) else {
            return req.eventLoop.future(AppResponse(code: .badRequest, error: .customString(self.generateUnableToFindAny(forRequested: T.self, for: .GET)), data: nil))
        }
        let isAscending = req.query[self.sortOrder] == self.ascending
        let isLikeWise = req.query[Bool.self, at: self.isLikeWise]
        let searchTerm = req.query[String.self, at: self.queryString]
        return T.find(idValue, on: req.db)
            .unwrap(orError: AppResponse<T>(code: .notFound, error: .customString(self.generateUnableToFind(forRequested: idValue)), data: nil))
            .flatMap { user in
                let userQueryBuilder: QueryBuilder<NotesController.T> = user.$notes.query(on: req.db)
                if let searchTerm,let isLikeWise {
                    if isLikeWise {
                        userQueryBuilder.group(.or) { or in
                            or.filter(\.filterSearchItem ~~ searchTerm)
                        }
                    } else {
                        userQueryBuilder.group(.or) { or in
                            or.filter(\.filterSearchItem == searchTerm)
                        }
                    }
                }
                return userQueryBuilder.sort(\.someComparable, isAscending ? .ascending : .descending)
                    .all()
            }.mappedToSuccessResponse()
    }
    
    @Sendable
    func getNotesForTheUser() -> Route {
        let path = (finalComponents().byAdding(.constant(self.notes)))
        return app.get(path, use: getNotesForTheUserHandler)
    }
    
    @discardableResult
    func deleteTheCodableObject() -> Route {
        app.delete(finalComponents(),use: deleteTheCodableObjectHandler)
    }
    
    @Sendable
    func deleteTheCodableObjectHandler(_ req: Request) -> NoteEventLoopFuture<T> {
        guard let idValue = req.parameters.getCastedTID(name: User.objectIdentifierKey,T.self) else {
            return req.eventLoop.future(AppResponse(code: .badRequest, error: .customString(self.generateUnableToFindAny(forRequested: T.self, for: .DELETE)), data: nil))
        }
        return T.find(idValue, on: req.db)
            .flatMap { wrapped -> NoteEventLoopFuture<T>  in
                if let wrapped {
                    let value = wrapped
                        .delete(on: req.db)
                        .transform(to: wrapped.successResponse())
                    return value
                } else {
                    return req.eventLoop.future(AppResponse<T>(code: .notFound, error: .customString(self.generateUnableToFind(forRequested: idValue)), data: nil))
                }
            }
    }
    
    @discardableResult
    func putTheCodableObject() -> Route {
        app.put(finalComponents(),use: putTheCodableObjectHandler)
    }
    
    @Sendable
    func putTheCodableObjectHandler(_ req: Request) -> NoteEventLoopFuture<T> {
        do {
            let note = try req.content.decode(T.self, using: self.decoder)
            guard let idValue = req.parameters.getCastedTID(name: User.objectIdentifierKey,T.self) ?? note.id else {
                return req.eventLoop.future(AppResponse(code: .badRequest, error: .customString(self.generateUnableToFindAny(forRequested: T.self, for: .PUT)), data: nil))
            }
            let found = T.find(idValue, on: req.db)
            let mapped = found.flatMap { wrapped -> NoteEventLoopFuture<T>  in
                if let wrapped {
                    let value = wrapped
                        .requestUpdate(with: note)
                        .save(on: req.db)
                        .map { _ in
                            AppResponse<T>(code: .accepted, error: nil, data: wrapped)
                        }
                    return value
                } else {
                    return req.eventLoop.future(AppResponse(code: .badRequest, error: .customString(self.generateUnableToFind(forRequested: idValue)), data: nil))
                }
            }
            return mapped
        } catch {
            return req.eventLoop.future(AppResponse(code: .badRequest, error: .customString(error), data: nil))
        }
    }
    
}
