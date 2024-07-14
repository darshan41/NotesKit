//
//  GenericUsersController.swift
//
//
//  Created by Darshan S on 15/05/24.
//

import Vapor
import Fluent

class UsersController<T: User>: GenericRootController<T>,VersionedRouteCollection {
    
    private let userID: String = "userID"
    
    private typealias T = User
    
    override init(
        app: Application,
        version: APIVersion,
        decoder: JSONDecoder = AppDecoder.shared.iso8601JSONDeocoder
    ) {
        super.init(app: app, version: version, decoder: decoder)
    }
    
    func boot(routes: any Vapor.RoutesBuilder) throws {
        routes.add(getSpecificCodableObjectHavingID())
        routes.add(getAllCodableObjects())
        routes.add(postCreateCodableObject())
        routes.add(deleteTheCodableObject())
        routes.add(putTheCodableObject())
    }
    
    override func generateUnableToFind(forRequested id: T.IDValue) -> String {
        "Unable to find the user for requested id: \(id)"
    }
    
    override func apiPathComponent() -> [PathComponent] {
        super.apiPathComponent() + [.constant(User.schema)]
    }
    
    override func finalComponents() -> [PathComponent] {
        apiPathComponent() + pathVariableComponents()
    }
    
    override func pathVariableComponents() -> [PathComponent] {
        [.parameter(.id)]
    }
}

extension UsersController {
    
    @discardableResult
    func postCreateCodableObject() -> Route {
        app.post(apiPathComponent(),use: postCreateCodableObjectHandler)
    }
    
    @Sendable
    func postCreateCodableObjectHandler(_ req: Request) -> NoteEventLoopFuture<T> {
        do {
            let note = try req.content.decode(T.self, using: self.decoder)
            return note.save(on: req.db).map {
                AppResponse<T>(code: .created, error: nil, data: note)
            }
        } catch {
            return req.eventLoop.future(AppResponse(code: .badRequest, error: .customString(error), data: nil))
        }
    }
    
    @discardableResult
    func getAllCodableObjects() -> Route {
        app.get(apiPathComponent(), use: getAllCodableObjectsHandler)
    }
    
    @Sendable
    func getAllCodableObjectsHandler(_ req: Request)
    -> NotesEventLoopFuture<T> {
        T.query(on: req.db).all().map { results in
            AppResponse(code: .ok, error: nil, data: results)
        }
    }
    
    @discardableResult
    func getSpecificCodableObjectHavingID() -> Route {
        app.get(finalComponents(),use: getSpecificCodableObjectHavingIDHandler)
    }
    
    @Sendable
    func getSpecificCodableObjectHavingIDHandler(_ req: Request) -> NoteEventLoopFuture<T> {
        guard let idValue = req.parameters.getCastedTID(T.self) else {
            return req.eventLoop.future(AppResponse(code: .badRequest, error: .customString(self.generateUnableToFindAny(forRequested: T.self, for: .GET)), data: nil))
        }
        return T.find(idValue, on: req.db).flatMap { value in
            if let wrapped = value {
                return req.eventLoop.future(AppResponse<T>(code: .ok, error: nil, data: wrapped))
            } else {
                return req.eventLoop.future(AppResponse<T>(code: .notFound, error: .customString(self.generateUnableToFind(forRequested: idValue)), data: nil))
            }
        }
    }
    
    @discardableResult
    func deleteTheCodableObject() -> Route {
        app.delete(finalComponents(),use: deleteTheCodableObjectHandler)
    }
    
    @Sendable
    func deleteTheCodableObjectHandler(_ req: Request) -> NoteEventLoopFuture<T> {
        guard let idValue = req.parameters.getCastedTID(T.self) else {
            return req.eventLoop.future(AppResponse(code: .badRequest, error: .customString(self.generateUnableToFindAny(forRequested: T.self, for: .DELETE)), data: nil))
        }
        return T.find(idValue, on: req.db)
            .flatMap { wrapped -> NoteEventLoopFuture<T>  in
                if let wrapped {
                    let value = wrapped
                        .delete(on: req.db)
                        .transform(to: AppResponse<T>(code: .ok, error: nil, data: wrapped))
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
            guard let idValue = req.parameters.getCastedTID(T.self) ?? note.id else {
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
