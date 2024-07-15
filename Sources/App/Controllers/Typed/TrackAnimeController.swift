//
//  NotesController.swift
//
//
//  Created by Darshan S on 21/06/24.
//

import Vapor
import Fluent

class TrackAnimeController: GenericItemController<Anime> {
    
    private typealias T = Anime
    
    private let search: String = "search"
    private let queryString: String = "query"
    private let sorted: String = "sorted"
    private let sortOrder: String = "sortOrder"
    private let ascending: String = "ascending"
    
    override func boot(routes: any Vapor.RoutesBuilder) throws {
        try super.boot(routes: routes)
        routes.add(getAllNotesInSorted())
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

extension TrackAnimeController {
    
    @discardableResult
    func getAllNotesInSorted() -> Route {
        app.get(apiPathComponent().byAdding(.constant(sorted)),use: getAllNotesInSortedHandler)
    }
    
    @Sendable
    private func getAllNotesInSortedHandler(_ req: Request) -> NotesEventLoopFuture<T> {
        let isAscending = req.query[self.sortOrder] == self.ascending
        return T.query(on: req.db).sort(\.someComparable,isAscending ? .ascending : .descending).all().map { results in
            AppResponse(code: .ok, error: nil, data: results)
        }
    }
}

// MARK: Helper func's

private extension NotesController {
    
}
