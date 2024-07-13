//
//  NotesController.swift
//
//
//  Created by Darshan S on 21/06/24.
//

import Vapor
import Fluent

class NotesController: GenericItemController<Note> {
    
    private typealias T = Note
    
    private let search: String = "search"
    private let queryString: String = "query"
    private let sorted: String = "sorted"
    private let sortOrder: String = "sortOrder"
    private let ascending: String = "ascending"
    private let isLikeWise: String = "isLikeWise"
    private let filter: String = "filter"
    
    
    override func boot(routes: any Vapor.RoutesBuilder) throws {
        try super.boot(routes: routes)
        routes.add(getAllNotesInSorted())
        routes.add(getAllNotesInFiltered())
    }
    
    override func generateUnableToFind(forRequested id: UUID) -> String {
        "Unable to find the note for requested id: \(id)"
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
    
}

// MARK: Helper func's

private extension NotesController {
    
}
