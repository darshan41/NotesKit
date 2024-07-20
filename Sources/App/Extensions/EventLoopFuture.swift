//
//  EventLoopFuture.swift
//
//
//  Created by Darshan S on 12/05/24.
//

import Fluent
import Vapor

public protocol ContentSendable: Content & Sendable { }

public protocol OptionalType {
    
    associatedtype Wrapped
    
    var optional: Wrapped? { get }
}

extension Optional: OptionalType {
    
    public var optional: Wrapped? { self }
}

public enum CoverResult<Success, Failure> where Failure : Error,Success: Content {
    
    case success(Success)
    case failure(Failure)
}

public extension Optional where Wrapped: Content {
    
    func getElseError(
        successCode: HTTPResponseStatus,
        errorCode: HTTPResponseStatus,
        error: ErrorMessage
    ) -> CoverResult<AppResponse<Wrapped>,AppResponse<Wrapped>>  {
        switch self {
        case .none:
            return .failure(.init(code: errorCode, error: error, data: nil))
        case .some(let wrapped):
            return .success(wrapped.successResponse(successCode))
        }
    }
}

public extension EventLoopFuture where Value: Content {
    
    typealias NewContentTransform<NewValue: Content> = @Sendable (Value) -> NewValue
    typealias NewContentAppResponseTransform<NewValue: Content> = @Sendable (Value) -> AppResponse<NewValue>
    
    func successResponse(_ code: HTTPResponseStatus = .ok) -> EventLoopFuture<AppResponse<Value>> {
        map { AppResponse(code: code, error: nil, data: $0) }
    }
}

public extension EventLoopFuture where Value: Collection,Value: Content,Value.Element: Content {
    
    typealias ContentTransform<NewValue: Content> = @Sendable (Value.Element) -> NewValue
    
    func transformElementsWithEventLoopAppResponse<DTO: Content>(
        _ code: HTTPResponseStatus = .ok,
        using transform: @escaping ContentTransform<DTO>
    ) -> EventLoopFuture<AppResponse<[DTO]>> {
        self.transformElements(using: transform).successResponse(code)
    }
    
    func transformElements<DTO: Content>(
        using transform: @escaping ContentTransform<DTO>
    ) -> EventLoopFuture<[DTO]> {
        map { collection in
            collection.map(transform)
        }
    }
    
    func mappedToSuccessResponse(_ code: HTTPResponseStatus = .ok) -> EventLoopFuture<AppResponse<Value>> {
        map { $0.successResponse(code) }
    }
}

public extension EventLoopFuture where Value: OptionalType,Value: ContentSendable,Value.Wrapped: ContentSendable {
    
    func wrappedFlattenElseError(
        successCode: HTTPResponseStatus,
        errorCode: HTTPResponseStatus,
        error: ErrorMessage
    ) -> EventLoopFuture<AppResponse<Value.Wrapped>> {
        self.flatMap { optionalValue in
            if let wrapped = optionalValue.optional {
                return self.eventLoop.makeSucceededFuture(wrapped.successResponse(successCode))
            } else {
                return self.eventLoop.mapFuturisticFailure(code: errorCode, error: error)
            }
        }
    }
}

public extension Request {
    
    func makeFutureSuccess<T: Content>(_ value: T,code: HTTPResponseStatus = .ok) -> EventLoopFuture<AppResponse<T>> {
        eventLoop.future(value.successResponse(code))
    }
    
    func mapFuturisticFailureOnThisEventLoop<T: Content>(
        code: HTTPResponseStatus,
        error: ErrorMessage,
        value: T.Type = T.self
    ) -> EventLoopFuture<AppResponse<T>> {
        eventLoop.mapFuturisticFailure(code: code, error: error, value: value)
    }
}

public extension Array where Element: Content {
    
    typealias NewContentTransform<NewValue: Content> = @Sendable (Self) -> NewValue
    
    func successResponse(_ code: HTTPResponseStatus = .ok) -> AppResponse<Self> {
        AppResponse(code: code, error: nil, data: self)
    }
    
    func successResponseMapNewValue<NewValue: Content>(
        _ code: HTTPResponseStatus = .ok,
        _ callback: @escaping NewContentTransform<NewValue>
    ) -> AppResponse<NewValue> {
        callback(self).successResponse(code)
    }
}

public extension EventLoop {
    
    func mapFuturisticFailure<T: Content>(
        code: HTTPResponseStatus,
        error: ErrorMessage,
        value: T.Type = T.self
    ) -> EventLoopFuture<AppResponse<T>> {
        future(AppResponse(code: code, error: error, data: nil))
    }
}

public extension Content {
    
    func successResponse(_ code: HTTPResponseStatus = .ok) -> AppResponse<Self> {
        AppResponse(code: code, error: nil, data: self)
    }
    
    func mapFailure(code: HTTPResponseStatus,error: ErrorMessage) -> AppResponse<Self> {
        AppResponse(code: code, error: error, data: nil)
    }
    
    func successResponseMapNewValue<NewValue: Content>(
        _ code: HTTPResponseStatus = .ok,
        _ callback: @escaping @Sendable (Self) -> (NewValue)
    ) -> AppResponse<NewValue> {
        callback(self).successResponse(code)
    }
}

public extension EventLoopFuture<Void> {
    
    func mapNewResponseFromVoid<NewValue: Content>(
        newValue: NewValue,
        _ code: HTTPResponseStatus = .ok
    ) -> EventLoopFuture<AppResponse<NewValue>> {
        self.eventLoop.makeSucceededFuture(AppResponse(code: code, error: nil, data: newValue))
    }
    
    func mappedToSuccess<T: Content & Sendable>(value: T,code: HTTPResponseStatus = .ok) -> AppResponse<T> {
        value.successResponse(code)
    }
}

public extension EventLoopFuture where Value: ContentSendable {
    
    func mappedToSuccess(value: Value,code: HTTPResponseStatus = .ok) -> AppResponse<Value> {
        value.successResponse(code)
    }
}

