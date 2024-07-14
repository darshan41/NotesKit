//
//  CustomErrorMiddleware.swift
//
//
//  Created by Darshan S on 13/05/24.
//

import Foundation
import Vapor

public final class CustomErrorMiddleware: Middleware {
    
    public static func `default`(environment: Environment) -> ErrorMiddleware {
        return .init { req, error in
            let status: HTTPResponseStatus, reason: String, source: ErrorSource
            var headers: HTTPHeaders
            switch error {
            case let debugAbort as (DebuggableError & AbortError):
                (reason, status, headers, source) = (debugAbort.reason, debugAbort.status, debugAbort.headers, debugAbort.source ?? .capture())
            case let abort as AbortError:
                (reason, status, headers, source) = (abort.reason, abort.status, abort.headers, .capture())
            case let debugErr as DebuggableError:
                (reason, status, headers, source) = (debugErr.reason, .internalServerError, [:], debugErr.source ?? .capture())
            case let error as AppResponseError:
                if (environment.isRelease) {
                    reason = "Something went wrong."
                    (status, headers, source) = (error.code, [:], .capture())
                } else {
                    reason = error.error?.errorDescription ?? error.localizedDescription
                    (status, headers, source) = (error.code, [:], .capture())
                }
            default:
                let error = (error as NSError)
                if (environment.isRelease) {
                    reason = "Something went wrong."
                    (status, headers, source) = (.internalServerError, [:], .capture())
                } else {
                    reason = error.description
                    (status, headers, source) = (.init(statusCode: error.code), [:], .capture())
                }
            }
            
            // Report the error
            req.logger.report(error: error, file: source.file, function: source.function, line: source.line)
            let body: Response.Body
            do {
                body = .init(
                    buffer: try JSONEncoder().encodeAsByteBuffer(AppResponse<String>(code: status, error: .customString(reason), data: nil, isServerGeneratedError: true), allocator: req.byteBufferAllocator),
                    byteBufferAllocator: req.byteBufferAllocator
                )
                headers.contentType = .json
            } catch {
                body = .init(string: "Oops: \(String(describing: error))\nWhile encoding error: \(reason)", byteBufferAllocator: req.byteBufferAllocator)
                headers.contentType = .plainText
            }
            return Response(status: status, headers: headers, body: body)
        }
    }
    
    private let closure: @Sendable (Request, Error) -> (Response)
    
    @preconcurrency
    public init(_ closure: @Sendable @escaping (Request, Error) -> (Response)) {
        self.closure = closure
    }
    
    public func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
#if DEBUG
        let url = request.url
        print("Request URL: \(url)")
        let urlComponents = request.url
        let path = urlComponents.path
        let query = urlComponents.query ?? ""
        print("Path: \(path)")
        print("Query: \(query)")
#endif
        return next.respond(to: request).flatMapErrorThrowing { error in
            self.closure(request, error)
        }
    }
}

