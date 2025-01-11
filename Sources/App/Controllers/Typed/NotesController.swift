//
//  NotesController.swift
//
//
//  Created by Darshan S on 21/06/24.
//

import Vapor
import Fluent

extension NotesKit {
    
    class NotesController: GenericRootController<Note>, VersionedRouteCollection, @unchecked Sendable {
        
        typealias T = Note
        
        private let search: String = "search"
        private let queryString: String = "query"
        private let sorted: String = "sorted"
        private let sortOrder: String = "sortOrder"
        private let ascending: String = "ascending"
        private let isLikeWise: String = "isLikeWise"
        private let filter: String = "filter"
        
        public override init<Manager: ApplicationManager>(
            kit: Manager,
            decoder: JSONDecoder = AppDecoder.shared.iso8601JSONDeocoder
        ) {
            super.init(kit: kit, decoder: decoder)
        }
        
        func boot(routes: any RoutesBuilder) throws {
            routes.add(getAllCodableObjects())
            routes.add(postCreateCodableObject())
            routes.add(getSpecificCodableObjectHavingID())
            routes.add(putTheCodableObject())
        }
        
        override func apiPathComponent() -> [PathComponent] {
            manager.usersController.finalComponents() + [.constant(T.schema)]
        }
        
        override func finalComponents() -> [PathComponent] {
            apiPathComponent() + pathVariableComponents()
        }
        
        override func pathVariableComponents() -> [PathComponent] {
            [.parameter(T.objectIdentifierKey)]
        }
        
        func getAllCodableObjects() -> Route {
            app.get(apiPathComponent()) { req -> NotesEventLoopFuture in
                T.query(on: req.db).all().mappedToSuccessResponse()
            }
        }
        
        @discardableResult
        func putTheCodableObject() -> Route {
            app.put(finalComponents(),use: putTheCodableObjectHandler)
        }
        
        @discardableResult
        func putTheCodableObjectOfTheUser() -> Route {
            app.put(finalComponents(),use: putTheCodableObjectHandler)
        }
        
        func getSpecificCodableObjectHavingID() -> Route {
            app.get(finalComponents()) { req -> NoteEventLoopFuture<T> in
                guard let idValue = req.parameters.getCastedTID(name: T.objectIdentifierKey, T.self) else {
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
        }
    }
}

// MARK: Public func's

extension NotesKit.NotesController {
    
    typealias NotesController = NotesKit.NotesController
    
    @discardableResult
    func getAllNotesInSorted() -> Route {
        app.get(apiPathComponent().byAdding(.constant(sorted))) { req -> NotesEventLoopFuture in
            let isAscending = req.query[self.sortOrder] == self.ascending
            return T.query(on: req.db).sort(\.someComparable,isAscending ? .ascending : .descending)
                .all()
                .successResponse()
        }
    }
    
    @discardableResult
    func getAllNotesInFiltered() -> Route {
        app.get(apiPathComponent().byAdding(.constant(filter))) { req -> NotesEventLoopFuture<T> in
            guard let searchTerm = req.query[String.self, at: self.queryString] else {
                return req.mapFuturisticFailureOnThisEventLoop(code: .badRequest, error: .customString(self.generateUnableToPerformOperationOnQuery(forRequested: self.queryString)), value: [T].self)
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
            return builder.all().mappedToSuccessResponse()
        }
    }
    
    @discardableResult
    func postCreateCodableObject() -> Route {
        app.post(apiPathComponent(), use: postCreateCodableObjectHandler)
    }
    
    @Sendable
    func postCreateCodableObjectHandler(_ req: Request) -> EventLoopFuture<AppResponse<T>> {
        req.perform { req in
            let note = try req.content.decode(T.self, using: self.decoder)
            return note.save(on: req.db).mapNewResponseFromVoid(newValue: note, .created)
        }
    }
    
    @Sendable
    func putTheCodableObjectHandler(_ req: Request) -> NoteEventLoopFuture<T> {
        do {
            let noteDTO = try req.content.decode(T.RequestDTO.self, using: self.decoder)
            let userId = try req.parameters.require(User.userId, as: User.IDValue.self)
            let note = Note(requestDto: noteDTO, userId: userId)
            guard let idValue = req.parameters.getCastedTID(name: T.objectIdentifierKey, T.self) else {
                return req.eventLoop.future(AppResponse(code: .badRequest, error: .customString(self.generateUnableToFindAny(forRequested: T.self, for: .PUT)), data: nil))
            }
            let found = T.find(idValue, on: req.db)
            let mapped = found.flatMap { wrapped -> NoteEventLoopFuture<T>  in
                if let wrapped {
                    let value = wrapped.requestUpdate(with: note)
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

// MARK: Helper func's

private extension NotesKit.NotesController {
    
}
