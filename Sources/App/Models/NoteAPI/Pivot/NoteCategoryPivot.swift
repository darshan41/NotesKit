//
//  NoteCategoryPivot.swift
//
//
//  Created by Darshan S on 20/07/24.
//

import Vapor
import Fluent

final class NoteCategoryPivot: SortableItem,@unchecked Sendable {
    
    static let objectIDKey: String = "''"
    
    typealias SortingValue = Date
    typealias FilteringValue = Date
    
    typealias T = FieldProperty<NoteCategoryPivot, SortingValue>
    typealias U = FieldProperty<NoteCategoryPivot, SortingValue>
        
    static let schema = "note-categories-pivot"
    static let objectIdentifierKey: String = "noteCategoryID"
    
    static let noteID: FieldKey = FieldKey("noteID")
    static let categoryID: FieldKey = FieldKey("categoryID")
    static let createdDate: FieldKey = FieldKey("createdDate")
    static let updatedDate: FieldKey = FieldKey("updatedDate")
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: noteID)
    var note: Note
    
    @Parent(key: categoryID)
    var category: Category
    
    @Field(key: createdDate)
    var createdDate: Date
    
    @Field(key: updatedDate)
    var updatedDate: Date
    
    init() {
        createdDate = Date()
        updatedDate = Date()
    }
    
    init(
        id: UUID? = nil,
        note: Note,
        category: Category
    ) throws {
        self.id = id
        self.$note.id = try note.requireID()
        self.$category.id = try category.requireID()
        self.createdDate = Date()
        self.updatedDate = Date()
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.$note.id = try container.decode(Note.self, forKey: .noteID).requireID()
        self.$category.id = try container.decode(Category.self, forKey: .categoryID).requireID()
        self.createdDate = Date()
        self.updatedDate = Date()
    }
}

extension NoteCategoryPivot {
    
    var someComparable: FluentKit.FieldProperty<NoteCategoryPivot, SortingValue> { self.$updatedDate }
    
    var filterSearchItem: FluentKit.FieldProperty<NoteCategoryPivot, SortingValue> { self.$createdDate }
    
    func requestUpdate(with newValue: NoteCategoryPivot) throws -> NoteCategoryPivot {
        self.$note.id = try newValue.note.requireID()
        self.$category.id = try newValue.category.requireID()
        self.updatedDate = Date()
        return self
    }
    
    func asNotableResponse(with status: HTTPResponseStatus, error: ErrorMessage?) -> AppResponse<NoteCategoryPivot> {
        .init(code: status, error: error, data: self)
    }
}

extension NoteCategoryPivot: Comparable {
    
    enum CodingKeys: String,CodingKey,Codable {
        case id
        case noteID
        case categoryID
    }
    
    static func < (lhs: NoteCategoryPivot, rhs: NoteCategoryPivot) -> Bool {
        lhs.updatedDate < rhs.updatedDate
    }
    
    static func == (lhs: NoteCategoryPivot, rhs: NoteCategoryPivot) -> Bool {
        lhs.id == rhs.id && lhs.note.id == rhs.note.id && lhs.category.id == rhs.category.id
    }
}


