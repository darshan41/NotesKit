//
//  Router.swift
//
//
//  Created by Darshan S on 12/05/24.
//

import Foundation
import Vapor

class Router {
    
    class var version: String { "v1" }
    
    private let app: Application
    
    init(app: Application) {
        self.app = app
    }
}

extension Router {
    
    @discardableResult
    func postCreateNote() -> Route {
        app.post(.constant(.api),.constant(.version), .constant(Router.ApiPath.createNote.keyValue)) { req -> EventLoopFuture<Note> in
            let note = try req.content.decode(Note.self, using: AppDecoder.shared.iso8601JSONDeocoder)
            return note.save(on: req.db).map {
                note
            }
        }
    }
}

extension String {
    
    fileprivate static let api: String = "api"
    
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
