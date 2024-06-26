//
//  NotesController.swift
//
//
//  Created by Darshan S on 21/06/24.
//

import Vapor
import Fluent

class NotesController: GenericItemController<Note> {
    
    private let search: String = "search"
    private let queryString: String = "query"
    private let sorted: String = "sorted"
    private let sortOrder: String = "sortOrder"
    private let ascending: String = "ascending"
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
        super.apiPathComponent() + [.constant(Note.schema)]
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
            return Note.query(on: req.db).sort(\.someComparable,isAscending ? .ascending : .descending).all().map { results in
                AppResponse(code: .ok, error: nil, data: results)
            }
        }
    }
    
    @discardableResult
    func getAllNotesInFiltered() -> Route {
        app.get(apiPathComponent().byAdding(.constant(filter))) { req -> NotesEventLoopFuture<Note> in
            guard let searchTerm = req.query[Note.self, at: self.queryString] else {
                return req.eventLoop.future(AppResponse<[Note]>(code: .badRequest, error: .customString(self.generateUnableToPerformOperationOnQuery(forRequested: self.queryString)), data: nil))
            }
            return Note.query(on: req.db).group(.or) { or in
                or.filter(\.$note == searchTerm.note)
            }.all().map { filteredNotes in
                AppResponse(code: .ok, error: nil, data: filteredNotes)
            }
        }
    }
    
}

// MARK: Helper func's

private extension NotesController {
    
}
