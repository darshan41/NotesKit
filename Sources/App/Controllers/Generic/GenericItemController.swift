//
//  GenericItemController.swift
//
//
//  Created by Darshan S on 12/05/24.
//

import Vapor
import Fluent
import Foundation

open class GenericItemController<T: Notable>: GenericRootController<T>,VersionedRouteCollection {
    
    open func boot(routes: any Vapor.RoutesBuilder) throws {
        print("Adding Routes on \(Self.self)")
        routes.add(getAllCodableObjects())
        routes.add(postCreateCodableObject())
        routes.add(getSpecificCodableObjectHavingID())
        routes.add(deleteTheCodableObject())
        routes.add(putTheCodableObject())
    }
    
    override func apiPathComponent() -> [PathComponent] {
        super.apiPathComponent()
    }
    
    override func finalComponents() -> [PathComponent] {
        super.finalComponents()
    }
    
    override func pathVariableComponents() -> [PathComponent] {
        super.pathVariableComponents()
    }
    
    @discardableResult
    open func postCreateCodableObject() -> Route {
        app.post(apiPathComponent(), use: postCreateCodableObjectHandler)
    }
    
    @Sendable
    open func postCreateCodableObjectHandler(_ req: Request) -> NoteEventLoopFuture<T> {
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
    open func getAllCodableObjects() -> Route {
        app.get(apiPathComponent(),use: getAllCodableObjectsHandler)
    }
    
    @Sendable
    open func getAllCodableObjectsHandler(_ req: Request) -> NotesEventLoopFuture<T> {
        T.query(on: req.db).all().mappedToSuccessResponse()
    }
    
    @Sendable
    open func getAllCodableObjectsHandler(_ req: Request) async throws -> AppResponse<[T]> {
        try await T.query(on: req.db).all().successResponse()
    }
    
    
    @discardableResult
    open func getSpecificCodableObjectHavingID() -> Route {
        app.get(finalComponents(),use: getSpecificCodableObjectHavingIDHandler)
    }
    
    @Sendable
    open func getSpecificCodableObjectHavingIDHandler(_ req: Request) -> NoteEventLoopFuture<T> {
        guard let idValue = req.parameters.getCastedTID(T.self) else {
            return req.mapFuturisticFailureOnThisEventLoop(code: .badRequest, error: .customString(self.generateUnableToFindAny(forRequested: T.self, for: .GET)))
        }
        return T.find(idValue, on: req.db).flatMap { value in
            if let wrapped = value {
                return req.makeFutureSuccess(with: wrapped)
            } else {
                return req.mapFuturisticFailureOnThisEventLoop(code: .notFound, error: .customString(self.generateUnableToFind(forRequested: idValue)))
            }
        }
    }
    
    @discardableResult
    open func deleteTheCodableObject() -> Route {
        app.delete(finalComponents(),use: deleteTheCodableObjectHandler)
    }
    
    @Sendable
    open func deleteTheCodableObjectHandler(_ req: Request) -> NoteEventLoopFuture<T> {
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
                    return req.mapFuturisticFailureOnThisEventLoop(code: .notFound, error: .customString(self.generateUnableToFind(forRequested: idValue)))
                }
            }
    }
    
    @discardableResult
    open func putTheCodableObject() -> Route {
        app.put(finalComponents(),use: putTheCodableObjectHandler)
    }
    
    @Sendable
    open func putTheCodableObjectHandler(_ req: Request) -> NoteEventLoopFuture<T> {
        do {
            let note = try req.content.decode(T.self, using: self.decoder)
            guard let idValue = req.parameters.getCastedTID(T.self) ?? note.id else {
                return req.eventLoop.future(AppResponse(code: .badRequest, error: .customString(self.generateUnableToFindAny(forRequested: T.self, for: .PUT)), data: nil))
            }
            let found = T.find(idValue, on: req.db)
            let mapped = found.flatMap { wrapped -> NoteEventLoopFuture<T>  in
                if let wrapped,let value = try? wrapped.requestUpdate(with: note) {
                    return value.save(on: req.db).mapNewResponseFromVoid(newValue: wrapped)
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
