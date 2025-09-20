//
//  File.swift
//  NotesKit
//
//  Created by Darshan S on 20/09/25.
//

import Vapor
import Fluent
import PostgresKit

extension NotesKit {
    
    class TestController: GenericRootController<QueryRun>, VersionedRouteCollection, @unchecked Sendable {
        
        typealias T = QueryRun
        
        public func boot(routes: any Vapor.RoutesBuilder) throws {
            routes.add(postCreateCodableObject())
        }
        
        override func apiPathComponent() -> [PathComponent] {
            super.apiPathComponent() + [.constant("test")]
        }
        
        func apiPathComponentForUserCategories() -> [PathComponent] {
            manager.usersController.finalComponents()
        }
        
        override func finalComponents() -> [PathComponent] {
            apiPathComponent() + pathVariableComponents()
        }
    }
}

extension NotesKit.TestController {
    
    @discardableResult
    func postCreateCodableObject() -> Route {
        app.post(apiPathComponent(), use: postCreateCodableObjectHandler)
    }
    
    @Sendable
    func postCreateCodableObjectHandler(_ req: Request) -> EventLoopFuture<AppResponse<T.QueryRunDTO>> {
        do {
            let queryRun = try req.content.decode(T.self, using: self.decoder)
            
            // Execute query with safety checks
            return executeQuery(queryRun: queryRun, on: req)
                .flatMap { executionResult in
                    // Update queryRun with execution results
                    if executionResult.success {
                        queryRun.markAsExecuted(result: executionResult.resultString)
                    } else {
                        queryRun.markExecutionFailed(error: executionResult.resultString)
                    }
                    
                    // Save the queryRun with execution results
                    return queryRun.save(on: req.db).map {
                        AppResponse(
                            code: .created,
                            error: nil,
                            data: T.QueryRunDTO(queryRun: queryRun)
                        )
                    }
                }
                .flatMapError { error in
                    // If query execution fails, still save the queryRun with error
                    queryRun.markExecutionFailed(error: error.localizedDescription)
                    
                    return queryRun.save(on: req.db).map {
                        AppResponse(
                            code: .created,
                            error: nil,
                            data: T.QueryRunDTO(queryRun: queryRun)
                        )
                    }
                }
            
        } catch {
            return req.eventLoop.future(AppResponse(code: .badRequest, error: .customString(error), data: nil))
        }
    }
    
}
    
extension NotesKit.TestController {

    struct QueryExecutionResult {
        let success: Bool
        let resultString: String
    }
    
    private func executeQuery(queryRun: QueryRun, on req: Request) -> EventLoopFuture<QueryExecutionResult> {
        let trimmed = queryRun.query.trimmingCharacters(in: .whitespacesAndNewlines)

        if queryRun.isSafe {
            // Only allow SELECT
            guard trimmed.uppercased().hasPrefix("SELECT") else {
                return req.eventLoop.future(
                    QueryExecutionResult(
                        success: false,
                        resultString: "Safe mode: Only SELECT queries allowed."
                    )
                )
            }
            return executeSelectQuery(query: trimmed, req: req)
        } else {
            return executeAnyQuery(query: trimmed, req: req)
        }
    }


    // Safe SELECT query
    private func executeSelectQuery(query: String, req: Request) -> EventLoopFuture<QueryExecutionResult> {
        let sql = req.db as! SQLDatabase
        return sql.raw(SQLQueryString(query)).all()
            .map { rows in
                let resultString = self.formatQueryResultsAsJSON(rows: rows, originalQuery: query)
                return QueryExecutionResult(success: true, resultString: resultString)
            }
            .flatMapError { error in
                req.eventLoop.future(
                    QueryExecutionResult(success: false, resultString: "Query failed: \(error.localizedDescription)")
                )
            }
    }

    // Unsafe query (returns JSON)
    private func executeAnyQuery(query: String, req: Request) -> EventLoopFuture<QueryExecutionResult> {
        let sql = req.db as! SQLDatabase
        return sql.raw(SQLQueryString(query)).all()
            .map { rows in
                let resultString = self.formatQueryResultsAsJSON(rows: rows, originalQuery: query)
                return QueryExecutionResult(success: true, resultString: resultString)
            }
            .flatMapError { error in
                req.eventLoop.future(
                    QueryExecutionResult(success: false, resultString: "Query failed: \(error.localizedDescription)")
                )
            }
    }

    // String formatter
    private func formatQueryResultsAsString(rows: [any SQLRow], originalQuery: String) -> String {
        guard let first = rows.first else { return "No rows returned." }
        let columns = first.allColumns

        var result = "QUERY: \(originalQuery)\n"
        result += "ROW COUNT: \(rows.count)\n\n"

        result += columns.joined(separator: " | ") + "\n"
        result += String(repeating: "-", count: columns.joined(separator: " | ").count) + "\n"

        for row in rows {
            let values = columns.map { col -> String in
                // Try decoding the column as String, fallback to Int/Double/NULL
                if let str: String = try? row.decode(column: col, as: String.self) {
                    return str
                } else if let int: Int = try? row.decode(column: col, as: Int.self) {
                    return String(int)
                } else if let dbl: Double = try? row.decode(column: col, as: Double.self) {
                    return String(dbl)
                } else {
                    return "NULL"
                }
            }
            result += values.joined(separator: " | ") + "\n"
        }

        return result
    }


    // JSON formatter
    private func formatQueryResultsAsJSON(rows: [any SQLRow], originalQuery: String) -> String {
        var data: [[String: Any]] = []

        for row in rows {
            var rowDict: [String: Any] = [:]
            for col in row.allColumns {
                if let str: String = try? row.decode(column: col, as: String.self) {
                    rowDict[col] = str
                } else if let int: Int = try? row.decode(column: col, as: Int.self) {
                    rowDict[col] = int
                } else if let dbl: Double = try? row.decode(column: col, as: Double.self) {
                    rowDict[col] = dbl
                } else {
                    rowDict[col] = NSNull()
                }
            }
            data.append(rowDict)
        }

        let meta: [String: Any] = [
            "query": originalQuery,
            "rowCount": rows.count,
            "executedAt": ISO8601DateFormatter().string(from: Date())
        ]

        let payload: [String: Any] = ["metadata": meta, "data": data]

        if let json = try? JSONSerialization.data(withJSONObject: payload, options: [.prettyPrinted]) {
            return String(data: json, encoding: .utf8) ?? "{}"
        } else {
            return "{}"
        }
    }


}
