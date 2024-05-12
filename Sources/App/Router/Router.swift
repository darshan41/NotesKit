//
//  Router.swift
//
//
//  Created by Darshan S on 12/05/24.
//

import Foundation
import Vapor
import Fluent

protocol Modelable: Model & Content {
    
    func asNotableResponse(with status: HTTPResponseStatus,error: ErrorMessage?) -> NoteResponse<Self>
    
}

protocol Postable: Modelable {
    
}

protocol Deletable: Modelable {
    
}

protocol UpdateIble: Modelable {
    
    func requestUpdate(with newValue: Self) -> Self
}

protocol Getable: Modelable {
    
}

protocol Notable: Postable,Getable,UpdateIble,Deletable { }

typealias NoteEventLoopFuture<T: Model & Content> = EventLoopFuture<NoteResponse<T>>
typealias NotesEventLoopFuture<T: Model & Content> = EventLoopFuture<NoteResponse<[T]>>

class Router<T: Notable>: @unchecked Sendable {
    
    class var version: String { "v1" }
    private (set)var decoder: JSONDecoder
    
    private let app: Application
    
    init(app: Application,decoder: JSONDecoder = AppDecoder.shared.iso8601JSONDeocoder) {
        self.app = app
        self.decoder = decoder
    }
}

extension Router {
    
    @discardableResult
    func postCreateNote() -> Route {
        app.post(.constant(.api),.constant(.version), .constant(Router.ApiPath.createNote.keyValue)) { req -> NoteEventLoopFuture in
            do {
                let note = try req.content.decode(T.self, using: self.decoder)
                return note.save(on: req.db).map {
                    NoteResponse<T>(code: .created, error: nil, data: note)
                }
            } catch {
                return req.eventLoop.future(NoteResponse(code: .badRequest, error: .customString(error.localizedDescription), data: nil))
            }
        }
    }
    
    @discardableResult
    func getNote() -> Route {
        app.get(.constant(.api),.constant(.version), .constant(Router.ApiPath.createNote.keyValue)) { req -> NotesEventLoopFuture in
            T.query(on: req.db).all().map { results in
                NoteResponse(code: .ok, error: nil, data: results)
            }
        }
    }
    
    @discardableResult
    func getSpecificHavingIDNote() -> Route {
        app.get(.constant(.api),.constant(.version),    .constant(Router.ApiPath.createNote.keyValue),.parameter(String.id)) { req -> NoteEventLoopFuture<T> in
            guard let idValue = req.parameters.get(.id, as: String.self) as? T.IDValue else {
                return req.eventLoop.future(error: Abort(.internalServerError))
            }
            return T.find(idValue, on: req.db).flatMap { value in
                if let wrapped = value {
                    return req.eventLoop.future(NoteResponse<T>(code: .ok, error: nil, data: wrapped))
                } else {
                    return req.eventLoop.future(NoteResponse<T>(code: .notFound, error: .customString("Unable to find the ID\(idValue as? String ?? ".")"), data: nil))
                }
            }
        }
    }
    
    @discardableResult
    func putTheNote() -> Route {
        app.put(.constant(.api),.constant(.version),    .constant(Router.ApiPath.createNote.keyValue),.parameter(String.id)) { req -> NoteEventLoopFuture<T> in
            do {
                let note = try req.content.decode(T.self, using: self.decoder)
                guard let idValue = req.parameters.get(.id, as: String.self) as? T.IDValue else {
                    return req.eventLoop.future(error: Abort(.internalServerError))
                }
                let found = T.find(idValue, on: req.db)
                let mapped = found.flatMap { wrapped -> NoteEventLoopFuture<T>  in
                    if let wrapped {
                        let value = wrapped
                            .requestUpdate(with: note)
                            .save(on: req.db)
                            .map { value in
                                NoteResponse<T>(code: .created, error: nil, data: note)
                            }
                        return value
                    } else {
                        return req.eventLoop.future(NoteResponse(code: .badRequest, error: .customString("Unable to find the note with requested id: \(req.parameters.get(.id) ?? "None")"), data: nil))
                    }
                }
                return mapped
            } catch {
                return req.eventLoop.future(NoteResponse(code: .badRequest, error: .customString(error.localizedDescription), data: nil))
            }
        }
    }
}

extension String {
    
    fileprivate static let api: String = "api"
    fileprivate static var id: String { "id" }
    fileprivate static let version: String = "v1"
}

extension Router {
    
    enum ApiPath: String {
        case createNote
    }
    
}

extension Router.ApiPath {
    
    var keyValue: String {
        switch self {
        case .createNote:
            return "note"
        }
    }
}

extension EventLoopFuture where Value: Notable {
    
    var customResponse: EventLoopFuture<NoteResponse<Value>> {
        map { NoteResponse(code: .ok, error: nil, data: $0) }
    }
}

