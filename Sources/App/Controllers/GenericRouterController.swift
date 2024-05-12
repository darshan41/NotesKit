//
//  Router.swift
//
//
//  Created by Darshan S on 12/05/24.
//

import Vapor
import Fluent

open class GenericRouterController<T: Notable>: @unchecked Sendable,VersionedRouteCollection {
    
    private (set)var decoder: JSONDecoder
    
    private let app: Application
    private (set)open var version: APIVersion
        
    public init(
        app: Application,
        version: APIVersion,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.app = app
        self.version = version
        self.decoder = decoder
    }
    
    open func boot(routes: any Vapor.RoutesBuilder) throws {
        routes.add(getAllCodableObjects())
        routes.add(postCreateCodableObject())
        routes.add(getSpecificCodableObjecctHavingID())
        routes.add(deleteTheCodableObject())
        routes.add(putTheCodableObject())
    }
    
    /// By Default All POST and Get use this.... as last path.
    /// - Returns: PathComponent
    /// eg: http://127.0.0.1:8080/api/v1/note
    open func apiPathComponent() -> [PathComponent] {
        version.apiPath
    }
    
    /// The Query Components for DELETE,GET(with id) or Put
    /// - Returns: PathComponent
    /// /// eg: http://127.0.0.1:8080/api/v1/note/:id
    open func pathVariableComponents() -> [PathComponent] {
        return []
    }
    
    /// Combines the apiPathComponent() and pathVariableComponents() to build, use overides carefully.
    /// - Returns: PathComponent
    open func finalComponents() -> [PathComponent] {
        apiPathComponent() + pathVariableComponents()
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
                return req.eventLoop.future(AppResponse(code: .badRequest, error: .customString(error.localizedDescription), data: nil))
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
    open func getSpecificCodableObjecctHavingID() -> Route {
        app.get(finalComponents()) { req -> NoteEventLoopFuture<T> in
            guard let idValue = req.parameters.getCastedTID(T.self) else {
                return req.eventLoop.future(error: Abort(.notFound))
            }
            return T.find(idValue, on: req.db).flatMap { value in
                if let wrapped = value {
                    return req.eventLoop.future(AppResponse<T>(code: .ok, error: nil, data: wrapped))
                } else {
                    return req.eventLoop.future(AppResponse<T>(code: .notFound, error: .customString("Unable to find the ID\(idValue as? String ?? ".")"), data: nil))
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
                            .transform(to: AppResponse<T>(code: .created, error: nil, data: wrapped))
                        return value
                    } else {
                        return req.eventLoop.future(AppResponse(code: .badRequest, error: .customString("Unable to find the note with requested id: \(req.parameters.get(.id) ?? "None")"), data: nil))
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
                            .map { value in
                                AppResponse<T>(code: .created, error: nil, data: note)
                            }
                        return value
                    } else {
                        return req.eventLoop.future(AppResponse(code: .badRequest, error: .customString("Unable to find the note with requested id: \(req.parameters.get(.id) ?? "None")"), data: nil))
                    }
                }
                return mapped
            } catch {
                return req.eventLoop.future(AppResponse(code: .badRequest, error: .customString(error.localizedDescription), data: nil))
            }
        }
    }
}
