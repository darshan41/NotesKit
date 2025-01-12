//
//  WebsiteController.swift
//  NotesKit
//
//  Created by Darshan S on 12/01/25.
//

import Vapor
import Leaf

public struct WebsiteController: RouteCollection, Sendable {
    
    public func boot(routes: RoutesBuilder) throws {
        routes.get(use: indexHandler)
        routes.get("notes", ":id", use: noteHandler)
    }
    
    @Sendable
    public func indexHandler(_ req: Request) -> EventLoopFuture<View> {
        Note.query(on: req.db).all().flatMap { notes in
            let notesData = notes.isEmpty ? nil : notes
            let context = IndexContext(
                title: "Home page",
                notes: notesData)
            return req.view.render("index", context)
        }
    }
    
    @Sendable
    public func noteHandler(_ req: Request) -> EventLoopFuture<View> {
        Note.find(req.parameters.get("id"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { wrappedNote -> EventLoopFuture<View> in
                let user = wrappedNote.$user.get(on: req.db)
                return user.flatMap { user in
                        let context = NoteContext(
                            title: "Note Details Page",
                            user: user,
                            authorName: user.name.name,
                            notes: [wrappedNote]
                        )
                        return req.view.render("note", context)
                    }
            }
        
    }
}

struct NoteContext: Encodable {
    let title: String
    let user: User
    let authorName: String
    let notes: [Note]?
}

struct IndexContext: Encodable {
    let title: String
    let notes: [Note]?
}

