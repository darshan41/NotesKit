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
        app.post(apiPathComponent()) { req -> NoteEventLoopFuture in
            do {
                let note = try req.content.decode(T.self, using: self.decoder)
                return note.save(on: req.db).map {
                    AppResponse<T>(code: .created, error: nil, data: note)
                }
            } catch {
                return req.eventLoop.future(AppResponse(code: .badRequest, error: .customString(error), data: nil))
            }
        }
    }
    
    @discardableResult
    open func getAllCodableObjects() -> Route {
        app.get(apiPathComponent()) { req -> NotesEventLoopFuture in
            T.query(on: req.db).all().map { results in
                AppResponse(code: .ok, error: nil, data: results)
            }
        }
    }
    
    @discardableResult
    open func getSpecificCodableObjectHavingID() -> Route {
        app.get(finalComponents()) { req -> NoteEventLoopFuture<T> in
            guard let idValue = req.parameters.getCastedTID(T.self) else {
                return req.eventLoop.future(error: Abort(.notFound))
            }
            return T.find(idValue, on: req.db).flatMap { value in
                if let wrapped = value {
                    return req.eventLoop.future(AppResponse<T>(code: .ok, error: nil, data: wrapped))
                } else {
                    return req.eventLoop.future(AppResponse<T>(code: .notFound, error: .customString(self.generateUnableToFind(forRequested: idValue)), data: nil))
                }
            }
        }
    }
    
    @discardableResult
    open func deleteTheCodableObject() -> Route {
        app.delete(finalComponents()) { req -> NoteEventLoopFuture<T> in
            guard let idValue = req.parameters.getCastedTID(T.self) else {
                return req.eventLoop.future(error: Abort(.notFound))
            }
            return T.find(idValue, on: req.db)
                .flatMap { wrapped -> NoteEventLoopFuture<T>  in
                    if let wrapped {
                        let value = wrapped
                            .delete(on: req.db)
                            .transform(to: AppResponse<T>(code: .ok, error: nil, data: wrapped))
                        return value
                    } else {
                        return req.eventLoop.future(AppResponse(code: .badRequest, error: .customString(self.generateUnableToFind(forRequested: idValue)), data: nil))
                    }
                }
        }
    }
    
    @discardableResult
    open func putTheCodableObject() -> Route {
        app.put(finalComponents()) { req -> NoteEventLoopFuture<T> in
            do {
                let note = try req.content.decode(T.self, using: self.decoder)
                guard let idValue = req.parameters.getCastedTID(T.self) ?? note.id else {
                    return req.eventLoop.future(error: Abort(.notFound))
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
}
