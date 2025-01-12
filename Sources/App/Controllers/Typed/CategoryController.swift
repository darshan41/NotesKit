//
//  Category.swift
//
//
//  Created by Darshan S on 15/07/24.
//

import Vapor
import Fluent

extension NotesKit {
    
    class CategoryController: GenericRootController<Category>, VersionedRouteCollection, @unchecked Sendable {
        
        private let notes: String = "notes"
        
        typealias T = Category
        
        private let search: String = "search"
        private let queryString: String = "query"
        private let sorted: String = "sorted"
        private let sortOrder: String = "sortOrder"
        private let ascending: String = "ascending"
        private let isLikeWise: String = "isLikeWise"
        private let filter: String = "filter"
        
        public func boot(routes: any Vapor.RoutesBuilder) throws {
            routes.add(getSpecificCodableObjectHavingID())
            routes.add(getAllCodableObjects())
            routes.add(postCreateCodableObject())
            routes.add(deleteTheCodableObject())
            routes.add(putTheCodableObject())
            routes.add(createCategoryRefereingANote())
            routes.add(getAllNotesForGivenCategoryGlobally())
            routes.add(getTheCategoryInfo())
            routes.add(deleteCategoryRefereingANote())
        }
        
        override func apiPathComponent() -> [PathComponent] {
            super.apiPathComponent() + [.constant(T.schema)]
        }
        
        func apiPathComponentForUserCategories() -> [PathComponent] {
            manager.usersController.finalComponents() + [.constant(T.schema)]
        }
        
        override func finalComponents() -> [PathComponent] {
            apiPathComponent() + pathVariableComponents()
        }
        
        override func pathVariableComponents() -> [PathComponent] {
            [.parameter(T.objectIdentifierKey)]
        }
    }
}

// MARK: Helper func's

extension NotesKit.CategoryController {
    
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
    
    @discardableResult
    func getAllNotesForGivenCategoryGlobally() -> Route {
        app.get(finalComponents() + [.parameter(Note.schema)], use: getAllNotesForGivenCategoryHandler)
    }
    
    @discardableResult
    func getTheCategoryInfo() -> Route {
        let pathComponent = manager.notesController.finalComponents() + [.constant(Category.schema),.parameter(Category.objectIdentifierKey)]
        let route = app.get(pathComponent, use: getSpecificCodableObjectHavingIDHandler)
        return route
    }
    
    @Sendable
    func getAllNotesForGivenCategoryHandler(_ req: Request) -> EventLoopFuture<AppResponse<[Note]>> {
        guard let categoryIDValue = req.parameters.getCastedTID(name: Category.objectIdentifierKey, Category.self) else {
            return req.mapFuturisticFailureOnThisEventLoop(code: .badRequest, error: .customString(self.generateUnableToFindAnyModel(forRequested: Category.self, for: req.method)))
        }
        return T.find(categoryIDValue, on: req.db)
            .flatMap { category -> EventLoopFuture<AppResponse<[Note]>> in
                if let category {
                    return category.$notes.get(on: req.db).mappedToSuccessResponse()
                } else {
                    return req.eventLoop.future(AppResponse(code: .notFound, error: .customString(self.generateUnableToFindAny(forRequested: T.self, for: req.method)), data: nil))
                }
            }
    }
    
    @discardableResult
    func createCategoryRefereingANote() -> Route {
        app.post(
            manager.notesController.finalComponents() + [.constant(T.schema)] + pathVariableComponents(),
            use: createCategoryRefereingANoteHandler
        )
    }
    
    @discardableResult
    func deleteCategoryRefereingANote() -> Route {
        app.delete(
            manager.notesController.finalComponents() + [.constant(T.schema)] + pathVariableComponents(),
            use: deleteCategoryRefereingANoteHandler
        )
    }
    
    @Sendable
    func createCategoryRefereingANoteHandler(_ req: Request) -> EventLoopFuture<AppResponse<Category>> {
        guard let noteIDValue = req.parameters.getCastedTID(name: Note.objectIdentifierKey, Note.self) else {
            return req.mapFuturisticFailureOnThisEventLoop(code: .badRequest, error: .customString(self.generateUnableToFindAnyModel(forRequested: Note.self, for: req.method)))
        }
        guard let categoryIDValue = req.parameters.getCastedTID(name: T.objectIdentifierKey, T.self) else {
            return req.mapFuturisticFailureOnThisEventLoop(code: .badRequest, error: .customString(self.generateUnableToFindAny(forRequested: T.self, for: req.method)))
        }
        let noteFinder = Note.find(noteIDValue, on: req.db)
            .unwrap(orError: AppResponse<Note>(code: .notFound, error: .customString(self.generateUnableToFindForModel(forRequested: noteIDValue,valueType: Note.self)), data: nil))
        let categoryFinder = T.find(categoryIDValue, on: req.db)
            .unwrap(orError: AppResponse<T>(code: .notFound, error: .customString(self.generateUnableToFind(forRequested: categoryIDValue)), data: nil))
        return noteFinder.and(categoryFinder)
            .flatMap { note, category in
                note
                    .$categories
                    .attach(category, on: req.db)
                    .transform(to: AppResponse<Category>.init(code: .created, error: nil, data: category))
            }
    }
    
    @Sendable
    func deleteCategoryRefereingANoteHandler(_ req: Request) -> EventLoopFuture<AppResponse<Category>> {
        guard let noteIDValue = req.parameters.getCastedTID(name: Note.objectIdentifierKey, Note.self) else {
            return req.mapFuturisticFailureOnThisEventLoop(code: .badRequest, error: .customString(self.generateUnableToFindAnyModel(forRequested: Note.self, for: req.method)))
        }
        guard let categoryIDValue = req.parameters.getCastedTID(name: T.objectIdentifierKey, T.self) else {
            return req.mapFuturisticFailureOnThisEventLoop(code: .badRequest, error: .customString(self.generateUnableToFindAny(forRequested: T.self, for: req.method)))
        }
        let noteFinder = Note.find(noteIDValue, on: req.db)
            .unwrap(orError: AppResponse<Note>(code: .notFound, error: .customString(self.generateUnableToFindForModel(forRequested: noteIDValue,valueType: Note.self)), data: nil))
        let categoryFinder = T.find(categoryIDValue, on: req.db)
            .unwrap(orError: AppResponse<T>(code: .notFound, error: .customString(self.generateUnableToFind(forRequested: categoryIDValue)), data: nil))
        return noteFinder.and(categoryFinder)
            .flatMap { note, category in
                note
                    .$categories
                    .detach(category, on: req.db)
                    .transform(to: AppResponse<Category>.init(code: .ok, error: nil, data: category))
            }
    }
    
    @Sendable
    func getAllCodableObjectsHandler(_ req: Request)
    -> EventLoopFuture<AppResponse<[Category.CategoryDTO]>> {
        let builder: QueryBuilder<T>
        if let searchTerm = req.query[String.self, at: self.queryString], !searchTerm.isEmpty {
            let isLikeWise = req.query[Bool.self, at: self.isLikeWise] ?? false
            if isLikeWise {
                builder = T.query(on: req.db).group(.or) { or in
                    or.filter(\.$name == searchTerm)
                }
            } else {
                builder = T.query(on: req.db).group(.or) { or in
                    or.filter(\.$name ~~ searchTerm)
                }
            }
        } else {
            builder = T.query(on: req.db)
        }
        if let sortOrder: String = req.query[self.sortOrder] {
            let isAscending = req.query[sortOrder] == self.ascending
            builder.sort(\.$updatedDate, isAscending ? .ascending : .descending)
        }
        return builder.all().transformElementsWithEventLoopAppResponse(using: { Category.CategoryDTO(category: $0) })
    }
    
    @discardableResult
    func getSpecificCodableObjectHavingID() -> Route {
        app.get(finalComponents(),use: getSpecificCodableObjectHavingIDHandler)
    }
    
    @Sendable
    func getSpecificCodableObjectHavingIDHandler(_ req: Request) -> NoteEventLoopFuture<T> {
        guard let idValue = req.parameters.getCastedTID(name: T.objectIdentifierKey, T.self) else {
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
        guard let idValue = req.parameters.getCastedTID(name: T.objectIdentifierKey, T.self) else {
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
            guard let idValue = req.parameters.getCastedTID(name: T.objectIdentifierKey, T.self) ?? note.id else {
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

