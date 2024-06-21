//
//  GenericNotesController.swift
//
//
//  Created by Darshan S on 13/05/24.
//

import Vapor
import Fluent

@available(*, unavailable)
class GenericNotesController<T: SortableItem, U: FieldProperty<T, T.FilteringValue>>: GenericItemController<T> where T.FilteringValue == U.Value {
    
    private let search: String = "search"
    private let queryString: String = "query"
    private let sorted: String = "sorted"
    private let filter: String = "filter"
    private let sortOrder: String = "sortOrder"
    private let ascending: String = "ascending"
    
    override init(
        app: Application,
        version: APIVersion,
        decoder: JSONDecoder = AppDecoder.shared.iso8601JSONDeocoder
    ) {
        super.init(app: app, version: version, decoder: AppDecoder.shared.iso8601JSONDeocoder)
    }
    
    override func boot(routes: any RoutesBuilder) throws {
        try super.boot(routes: routes)
        routes.add(getAllNotesInSorted())
        routes.add(getAllNotesInFiltered())
    }
    
    override func generateUnableToFind(forRequested id: T.IDValue) -> String {
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
    
    override func getAllCodableObjects() -> Route {
        app.get(apiPathComponent()) { req -> NotesEventLoopFuture in
            T.query(on: req.db).all().map { results in
                AppResponse(code: .ok, error: nil, data: results)
            }
        }
    }
    
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
            guard let searchTerm = req.query[U.Value.self, at: self.queryString] else {
                return req.eventLoop.future(AppResponse<[T]>(code: .badRequest, error: .customString(self.generateUnableToPerformOperationOnQuery(forRequested: self.queryString)), data: nil))
            }
            return T.query(on: req.db).group(.or) { or in
                or.filter(\.filterSearchItem == searchTerm)
            }.all().map { filteredNotes in
                AppResponse(code: .ok, error: nil, data: filteredNotes)
            }
        }
    }
}
