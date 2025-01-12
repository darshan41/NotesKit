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

public protocol AppResponseError: ErrorShowable {    
    var isServerGeneratedError: Bool { get }
    var debugErrorDescription: String { get }
    var code: HTTPResponseStatus { get }
    var error: ErrorMessage? { get }
}


extension ErrorShowable {
//    public var identifier: String { "\(Self.self)" }
}


public typealias NoteEventLoopFuture<T: Model & Content> = EventLoopFuture<AppResponse<T>>
public typealias NotesEventLoopFuture<T: Model & Content> = EventLoopFuture<AppResponse<[T]>>

public protocol Modelable: CustomModel & Content {
    
    /// Must be the @ID's Key
    static var objectIdentifierKey: String { get }
    
    func asNotableResponse(with status: HTTPResponseStatus,error: ErrorMessage?) -> AppResponse<Self>
    
}

public protocol Postable: Modelable { }

public protocol Deletable: Modelable { }

public protocol UpdateIble: Modelable {
    
    func requestUpdate(with newValue: Self) throws -> Self
}

public protocol Getable: Modelable { }

public protocol Notable: Postable,Getable,UpdateIble,Deletable { }

public protocol CustomModel: Model {
    
    static var schema: String { get }
    static var objectTitleForErrorTitle: String { get }
}

extension CustomModel {
    
    static var objectTitleForErrorTitle: String {
        schema.hasSuffix("s") ? String(schema[..<schema.index(before: schema.endIndex)]) : schema
    }
}

/// Cool, Very Cool
public protocol SortableItem: Notable {
    
    typealias AProperAssociatedObject =  Decodable & Encodable & Sendable & Comparable & Equatable
    
    associatedtype SortingValue: AProperAssociatedObject
    associatedtype FilteringValue: AProperAssociatedObject
    
    associatedtype T: FieldProperty<Self, SortingValue>
    associatedtype U: FieldProperty<Self, FilteringValue>
    
    var someComparable: T { get }
    var filterSearchItem: U { get }
}

public protocol SortableGenericItem: Notable {
    
    typealias AProperAssociatedObject = Codable & Sendable & Comparable & Equatable
    
    associatedtype SortingValue: AProperAssociatedObject
    associatedtype FilteringValue: AProperAssociatedObject
    
    associatedtype T: AProperAssociatedObject
    associatedtype U: AProperAssociatedObject
    
    var someComparable: any QueryableProperty { get }
    var filterSearchItem: any QueryableProperty { get }
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

