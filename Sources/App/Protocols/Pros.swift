//
//  Pros.swift
//
//
//  Created by Darshan S on 12/05/24.
//

import Vapor
import Fluent

public protocol ErrorShowable: Error,LocalizedError,Codable {
    var identifier: String { get }
    var reason: String { get }
    var isUserShowableErrorMessage: Bool { get }
}

extension ErrorShowable {
//    public var identifier: String { "\(Self.self)" }
}

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

/// Cool, Very Cool
public protocol SortableItem: Notable {
    
    typealias AProperAssociatedObject =  Decodable & Encodable & Sendable & Comparable
    
    associatedtype SortingValue: AProperAssociatedObject
    associatedtype FilteringValue: AProperAssociatedObject
    
    associatedtype T: FieldProperty<Self, SortingValue>
    associatedtype U: FieldProperty<Self, FilteringValue>
    
    var someComparable: T { get }
    var filterSearchItem: U { get }
}

extension Modelable {
    
    var jsonString: NSString? {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        do {
            let jsonData = try jsonEncoder.encode(self)
            guard let string = String(data: jsonData, encoding: .utf8) else { return nil }
            return NSString(string: string)
        } catch {
            return nil
        }
    }
}
