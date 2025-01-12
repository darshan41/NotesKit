//
//  Category.swift
//
//
//  Created by Darshan S on 15/07/24.
//

import Foundation
import Fluent
import Vapor

final class Category: SortableGenericItem, @unchecked Sendable,Encodable {
    
    static let schema = "categories"
    static let objectIdentifierKey: String = "categoryID"
    static let uniqueNameKey: String = "nameUniqueKeyConstraint"
    
    static let name: FieldKey = FieldKey("name")
    static let createdDate: FieldKey = FieldKey("createdDate")
    static let updatedDate: FieldKey = FieldKey("updatedDate")
    
    
    typealias T = Date
    typealias U = String
    
    typealias SortingValue = FilteringValue
    typealias FilteringValue = Date
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: name)
    var name: String
    
    @Field(key: createdDate)
    var createdDate: Date
    
    @Field(key: updatedDate)
    var updatedDate: Date
    
    @Siblings(
        through: NoteCategoryPivot.self,
        from: \.$category,
        to: \.$note)
    var notes: [Note]
    
    init() { }
    
    init(
        id: UUID? = nil,
        name: String
    ) {
        self.id = id
        self.name = name
        createdDate = Date()
        updatedDate = Date()
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.createdDate = Date()
        self.updatedDate = Date()
    }
}

extension Category {
    
    public struct CategoryDTO: Codable, Content {
        let id: Category.IDValue?
        let name: String
        let createdDate: Date
        let updatedDate: Date
        
        init(category: Category) {
            self.id = category.id
            self.name = category.name
            self.createdDate = category.createdDate
            self.updatedDate = category.updatedDate
        }
    }
    
    fileprivate enum CodingKeys: String,CodingKey {
        case id
        case name
        case createdDate
        case updatedDate
    }
    
    var someComparable: any FluentKit.QueryableProperty {
        $updatedDate
    }
    
    var filterSearchItem: any FluentKit.QueryableProperty {
        $name
    }
    
    func requestUpdate(with newValue: Category) -> Category {
        self.name = newValue.name
        self.updatedDate = Date()
        return self
    }
    
    func asNotableResponse(with status: HTTPResponseStatus, error: ErrorMessage?) -> AppResponse<Category> {
        .init(code: status, error: error, data: self)
    }
}


extension Category: Comparable {
    
    static func < (lhs: Category, rhs: Category) -> Bool {
        lhs.updatedDate < rhs.updatedDate
    }
    
    static func == (lhs: Category, rhs: Category) -> Bool {
        lhs.id == rhs.id
    }
}


