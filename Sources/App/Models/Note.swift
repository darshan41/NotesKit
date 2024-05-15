//
//  Note.swift
//  
//
//  Created by Darshan S on 11/05/24.
//

import Vapor
import Fluent

final class Note: SortableNotes,@unchecked Sendable {
    
    typealias T = FieldProperty<Note, SortingValue>
    typealias U = FieldProperty<Note, FilteringValue>
    
    typealias SortingValue = Date
    typealias FilteringValue = String
    
    static let schema = "notes"
    
    static let date: FieldKey = FieldKey("date")
    static let note: FieldKey = FieldKey("note")
    static let cardColor: FieldKey = FieldKey("cardColor")
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: note)
    var note: String
    
    @Field(key: cardColor)
    var cardColor: String
    
    @Field(key: date)
    var date: Date
    
    init() { }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id)
        self.cardColor = try container.decode(String.self, forKey: .cardColor)
        self.note = try container.decode(String.self, forKey: .note)
        self.date = Date.init(timeIntervalSince1970: try container.decode(Double.self, forKey: .date))
    }
    
    init(id: UUID? = nil, note: String, cardColor: String,date: Date) {
        self.id = id
        self.cardColor = cardColor
        self.note = note
        self.date = date
    }
    
    fileprivate enum CodingKeys: String,CodingKey {
        case id
        case cardColor
        case note
        case date
    }
    
    var someComparable: FluentKit.FieldProperty<Note, Date> { self.$date }
    var filterSearchItem: FluentKit.FieldProperty<Note, String> { self.$note }
}

extension Note {
        
    func requestUpdate(with newValue: Note) -> Note {
        note = newValue.note
        cardColor = newValue.cardColor
        date = newValue.date
        return self
    }
    
    func asNotableResponse(with status: HTTPResponseStatus, error: ErrorMessage?) -> AppResponse<Note> {
        .init(code: status, error: error, data: self)
    }
}

extension Note: Comparable {
    
    static func < (lhs: Note, rhs: Note) -> Bool {
        lhs.date < rhs.date
    }
    
    static func == (lhs: Note, rhs: Note) -> Bool {
        lhs.id == rhs.id
    }
}
