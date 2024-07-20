//
//  Category.swift
//
//
//  Created by Darshan S on 15/07/24.
//

import Vapor
import Fluent

class CategoryController<T: Category>: GenericRootController<T>,VersionedRouteCollection {
    
    private let notes: String = "notes"
    
    private typealias T = Category
    
    private let search: String = "search"
    private let queryString: String = "query"
    private let sorted: String = "sorted"
    private let sortOrder: String = "sortOrder"
    private let ascending: String = "ascending"
    private let isLikeWise: String = "isLikeWise"
    private let filter: String = "filter"
    
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
//        routes.add(getNotesForTheUser())
    }
    
    override func apiPathComponent() -> [PathComponent] {
        super.apiPathComponent() + [.constant(T.schema)]
    }
    
    override func finalComponents() -> [PathComponent] {
        apiPathComponent() + pathVariableComponents()
    }
    
    override func pathVariableComponents() -> [PathComponent] {
        [.parameter(.id)]
    }
}

extension CategoryController {
    
    @discardableResult
    func postCreateCodableObject() -> Route {
        app.post(apiPathComponent(),use: postCreateCodableObjectHandler)
    }
    
    @Sendable
    func postCreateCodableObjectHandler(_ req: Request) -> EventLoopFuture<AppResponse<Category.CategoryDTO>> {
        do {
            let category = try req.content.decode(T.self, using: self.decoder)
            return category.save(on: req.db).mapNewResponseFromVoid(newValue: Category.CategoryDTO(category: category))
        } catch {
            return req.mapFuturisticFailureOnThisEventLoop(code: .badRequest, error: .customString(error))
        }
    }
    
    @discardableResult
    func getAllCodableObjects() -> Route {
        app.get(apiPathComponent(), use: getAllCodableObjectsHandler)
    }
    
    @Sendable
    func getAllCodableObjectsHandler(_ req: Request)
    -> EventLoopFuture<AppResponse<[Category.CategoryDTO]>> {
        T.query(on: req.db).all().transformElementsWithEventLoopAppResponse(using: { Category.CategoryDTO(category: $0) })
    }
    
    @discardableResult
    func getSpecificCodableObjectHavingID() -> Route {
        app.get(finalComponents(),use: getSpecificCodableObjectHavingIDHandler)
    }
    
    @Sendable
    func getSpecificCodableObjectHavingIDHandler(_ req: Request) -> NoteEventLoopFuture<T> {
        guard let idValue = req.parameters.getCastedTID(T.self) else {
            return req.mapFuturisticFailureOnThisEventLoop(code: .badRequest, error: .customString(self.generateUnableToFindAny(forRequested: T.self, for: .GET)))
        }
        return T.find(idValue, on: req.db).flatMap { value in
            if let wrapped = value {
                return req.eventLoop.future(wrapped.successResponse())
            } else {
                return req.mapFuturisticFailureOnThisEventLoop(code: .notFound, error: .customString(self.generateUnableToFind(forRequested: idValue)))
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
                    return wrapped
                        .delete(on: req.db)
                        .mapNewResponseFromVoid(newValue: wrapped)
                } else {
                    return req.mapFuturisticFailureOnThisEventLoop(code: .notFound, error: .customString(self.generateUnableToFind(forRequested: idValue)))
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
                return req.mapFuturisticFailureOnThisEventLoop(code: .badRequest, error: .customString(self.generateUnableToFindAny(forRequested: T.self, for: .PUT)))
            }
            let found = T.find(idValue, on: req.db)
            let mapped = found.flatMap { wrapped -> NoteEventLoopFuture<T>  in
                if let wrapped {
                    let value = wrapped
                        .requestUpdate(with: note)
                        .save(on: req.db)
                    return value.mapNewResponseFromVoid(newValue: wrapped, .created)
                } else {
                    return req.mapFuturisticFailureOnThisEventLoop(code: .badRequest, error: .customString(self.generateUnableToFind(forRequested: idValue)))
                }
            }
            return mapped
        } catch {
            return req.mapFuturisticFailureOnThisEventLoop(code: .badRequest, error: .customString(error))
        }
    }
}

