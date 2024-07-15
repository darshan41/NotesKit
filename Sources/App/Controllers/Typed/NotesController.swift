//
//  NotesController.swift
//
//
//  Created by Darshan S on 21/06/24.
//

import Vapor
import Fluent

class NotesController: GenericRootController<Note>,VersionedRouteCollection {
    
    typealias T = Note
    
    private let search: String = "search"
    private let queryString: String = "query"
    private let sorted: String = "sorted"
    private let sortOrder: String = "sortOrder"
    private let ascending: String = "ascending"
    private let isLikeWise: String = "isLikeWise"
    private let filter: String = "filter"
    
    override init(app: Application, version: APIVersion, decoder: JSONDecoder = JSONDecoder()) {
        super.init(app: app, version: version)
    }
    
    func boot(routes: any RoutesBuilder) throws {
        routes.add(getAllCodableObjects())
        routes.add(postCreateCodableObject())
        routes.add(getSpecificCodableObjectHavingID())
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
    
    func getAllCodableObjects() -> Route {
        app.get(apiPathComponent()) { req -> NotesEventLoopFuture in
            return T.query(on: req.db).all().map { results in
                AppResponse(code: .ok, error: nil, data: results)
            }
        }
    }
    
    func getSpecificCodableObjectHavingID() -> Route {
        app.get(finalComponents()) { req -> NoteEventLoopFuture<T> in
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
    }
}

// MARK: Public func's

extension NotesController {
    
    @discardableResult
    func getAllNotesInSorted() -> Route {
        app.get(apiPathComponent().byAdding(.constant(sorted))) { req -> NotesEventLoopFuture in
            let isAscending = req.query[self.sortOrder] == self.ascending
            return T.query(on: req.db).sort(\.someComparable,isAscending ? .ascending : .descending).all().map { results in
                AppResponse(code: .ok, error: nil, data: results)
            }
        }
    }
    
    @discardableResult
    func getAllNotesInFiltered() -> Route {
        app.get(apiPathComponent().byAdding(.constant(filter))) { req -> NotesEventLoopFuture<T> in
            guard let searchTerm = req.query[String.self, at: self.queryString] else {
                return req.eventLoop.future(AppResponse<[T]>(code: .badRequest, error: .customString(self.generateUnableToPerformOperationOnQuery(forRequested: self.queryString)), data: nil))
            }
            let isLikeWise = req.query[Bool.self, at: self.isLikeWise] ?? false
            var builder: QueryBuilder<NotesController.T>
            if isLikeWise {
                builder = T.query(on: req.db).group(.or) { or in
                    or.filter(\.filterSearchItem == searchTerm)
                }
            } else {
                builder = T.query(on: req.db).group(.or) { or in
                    or.filter(\.filterSearchItem ~~ searchTerm)
                }
            }
            return builder.all().map { filteredNotes in
                AppResponse(code: .ok, error: nil, data: filteredNotes)
            }
        }
    }
    
    @discardableResult
    func postCreateCodableObject() -> Route {
        app.post(apiPathComponent(), use: postCreateCodableObjectHandler)
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
}

// MARK: Helper func's

private extension NotesController {
    
}
