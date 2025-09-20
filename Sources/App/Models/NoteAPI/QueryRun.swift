//
//  QueryRun.swift
//  NotesKit
//
//  Created by Darshan S on 20/09/25.
//

import Vapor
import Fluent

final class QueryRun: SortableGenericItem, @unchecked Sendable, Encodable {
    
    static let schema = "Queryruns"
    static let objectIdentifierKey: String = "queryId"
    
    // Field Keys
    static let query: FieldKey = FieldKey("query")
    static let safe: FieldKey = FieldKey("safe")
    static let isExecuted: FieldKey = FieldKey("isExecuted")
    static let executionResult: FieldKey = FieldKey("executionResult")
    static let executedAt: FieldKey = FieldKey("executedAt")
    static let createdDate: FieldKey = FieldKey("createdDate")
    static let updatedDate: FieldKey = FieldKey("updatedDate")
    
    typealias T = Date
    typealias U = String
    
    typealias SortingValue = FilteringValue
    typealias FilteringValue = Date
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: query)
    var query: String
    
    @Field(key: safe)
    var safe: Bool
    
    // Execution tracking fields
    @Field(key: isExecuted)
    var isExecuted: Bool
    
    @OptionalField(key: executionResult)
    var executionResult: String?
    
    @OptionalField(key: executedAt)
    var executedAt: Date?
    
    // Timestamps
    @Field(key: createdDate)
    var createdDate: Date
    
    @Field(key: updatedDate)
    var updatedDate: Date
    
    init() { }
    
    init(
        id: UUID? = nil,
        query: String,
        safe: Bool = false
    ) {
        self.id = id
        self.query = query
        self.safe = safe
        self.isExecuted = false
        self.executionResult = nil
        self.executedAt = nil
        self.createdDate = Date()
        self.updatedDate = Date()
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.query = try container.decode(String.self, forKey: .query)
        self.safe = (try? container.decode(String.self, forKey: .safe)) == "true"
        self.isExecuted = false
        self.executionResult = nil
        self.executedAt = nil
        self.createdDate = Date()
        self.updatedDate = Date()
    }
}

extension QueryRun {
    
    public struct QueryRunDTO: Codable, Content {
        let id: QueryRun.IDValue?
        let query: String
        let safe: Bool
        let isExecuted: Bool
        let executionResult: String?
        let executedAt: Date?
        let createdDate: Date
        let updatedDate: Date
        
        init(queryRun: QueryRun) {
            self.id = queryRun.id
            self.query = queryRun.query
            self.safe = queryRun.safe
            self.isExecuted = queryRun.isExecuted
            self.executionResult = queryRun.executionResult
            self.executedAt = queryRun.executedAt
            self.createdDate = queryRun.createdDate
            self.updatedDate = queryRun.updatedDate
        }
    }
    
    fileprivate enum CodingKeys: String, CodingKey {
        case id
        case query
        case safe
        case isExecuted
        case executionResult
        case executedAt
        case createdDate
        case updatedDate
    }
    
    var someComparable: any FluentKit.QueryableProperty {
        $updatedDate
    }
    
    var filterSearchItem: any FluentKit.QueryableProperty {
        $query
    }
    
    func requestUpdate(with newValue: QueryRun) -> QueryRun {
        self.query = newValue.query
        self.safe = newValue.safe
        self.updatedDate = Date()
        return self
    }
    
    func asNotableResponse(with status: HTTPResponseStatus, error: ErrorMessage?) -> AppResponse<QueryRun> {
        .init(code: status, error: error, data: self)
    }
    
    // Helper method to mark as executed
    func markAsExecuted(result: String, success: Bool = true) {
        self.isExecuted = success
        self.executionResult = result
        self.executedAt = Date()
        self.updatedDate = Date()
    }
    
    // Helper method to mark execution failed
    func markExecutionFailed(error: String) {
        self.isExecuted = false
        self.executionResult = "ERROR: \(error)"
        self.executedAt = Date()
        self.updatedDate = Date()
    }
}

extension QueryRun: Comparable {
    
    static func < (lhs: QueryRun, rhs: QueryRun) -> Bool {
        lhs.updatedDate < rhs.updatedDate
    }
    
    static func == (lhs: QueryRun, rhs: QueryRun) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Computed Properties for easier access
extension QueryRun {
    
    /// Alias for safe to match controller expectation
    var isSafe: Bool {
        get { safe }
        set { safe = newValue }
    }
    
    /// Check if query was successfully executed
    var wasSuccessfullyExecuted: Bool {
        return isExecuted && executionResult != nil && !executionResult!.hasPrefix("ERROR:")
    }
    
    /// Get execution status as string
    var executionStatus: String {
        if !isExecuted {
            return "Not executed"
        } else if wasSuccessfullyExecuted {
            return "Successfully executed"
        } else {
            return "Execution failed"
        }
    }
}
