//
//  Pros.swift
//
//
//  Created by Darshan S on 12/05/24.
//

import Vapor
import Fluent

public typealias NoteEventLoopFuture<T: Model & Content> = EventLoopFuture<AppResponse<T>>
public typealias NotesEventLoopFuture<T: Model & Content> = EventLoopFuture<AppResponse<[T]>>

public protocol Modelable: CustomModel & Content {
    
    func asNotableResponse(with status: HTTPResponseStatus,error: ErrorMessage?) -> AppResponse<Self>
    
}

public protocol Postable: Modelable { }

public protocol Deletable: Modelable { }

public protocol UpdateIble: Modelable {
    
    func requestUpdate(with newValue: Self) -> Self
}

public protocol Getable: Modelable { }

public protocol Notable: Postable,Getable,UpdateIble,Deletable { }

public protocol CustomModel: Model {
    
    static var schema: String { get }
}
