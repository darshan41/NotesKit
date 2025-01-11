//
//  GenericNotesController.swift
//
//
//  Created by Darshan S on 13/05/24.
//

import Vapor
import Fluent

@available(*, unavailable)
class GenericNotesController<T: SortableItem, U: FieldProperty<T, T.FilteringValue>>: GenericItemController<T>, @unchecked Sendable where T.FilteringValue == U.Value {
    
    private let search: String = "search"
    private let queryString: String = "query"
    private let sorted: String = "sorted"
    private let filter: String = "filter"
    private let sortOrder: String = "sortOrder"
    private let ascending: String = "ascending"
    
    public override init<Manager: ApplicationManager>(
        kit: Manager,
        decoder: JSONDecoder = AppDecoder.shared.iso8601JSONDeocoder
    ) {
        super.init(kit: kit, decoder: decoder)
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
    
    @discardableResult
    func getAllNotesInSorted() -> Route {
        app.get(apiPathComponent().byAdding(.constant(sorted)),use: getAllNotesInSorted)
    }
    
    @Sendable
    func getAllNotesInSorted(_ req: Request) -> NotesEventLoopFuture<T> {
        let isAscending = req.query[self.sortOrder] == self.ascending
        return T.query(on: req.db).sort(\.someComparable,isAscending ? .ascending : .descending).all().mappedToSuccessResponse()
    }
    
    @discardableResult
    func getAllNotesInFiltered() -> Route {
        app.get(apiPathComponent().byAdding(.constant(filter)),use: getAllNotesInFiltered)
    }
    
    @Sendable
    func getAllNotesInFiltered(_ req: Request) -> NotesEventLoopFuture<T> {
        guard let searchTerm = req.query[U.Value.self, at: self.queryString] else {
            return req.mapFuturisticFailureOnThisEventLoop(code: .badRequest, error: .customString(self.generateUnableToPerformOperationOnQuery(forRequested: self.queryString)), value: [T].self)
        }
        return T.query(on: req.db).group(.or) { or in
            or.filter(\.filterSearchItem == searchTerm)
        }.all().mappedToSuccessResponse()
    }
}
