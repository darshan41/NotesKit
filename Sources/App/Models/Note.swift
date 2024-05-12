//
//  Note.swift
//  
//
//  Created by Darshan S on 11/05/24.
//

import Vapor
import Fluent

final class Note: Notable,@unchecked Sendable {
    
    static let schema = "notes"
    static let date = "date"
    static let note = "note"
    static let cardColor = "cardColor"
    
    @ID(custom: .id)
    var id: UUID?
    
    @Field(key: .string(Note.note))
    var note: String
    
    @Field(key: .string(Note.cardColor))
    var cardColor: String
    
    @Field(key: .string(Note.date))
    var date: Date
    
    init() { }
    
    init(id: UUID? = nil, note: String, cardColor: String,date: Date) {
        self.id = id
        self.cardColor = cardColor
        self.note = note
        self.date = date
    }
    
    enum CodingKeys: String,CodingKey {
        case id
        case cardColor
        case note
        case date
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id)
        self.cardColor = try container.decode(String.self, forKey: .cardColor)
        self.note = try container.decode(String.self, forKey: .note)
        self.date = Date.init(timeIntervalSince1970: try container.decode(Double.self, forKey: .date))
    }
    
    func requestUpdate(with newValue: Note) -> Note {
        note = newValue.note
        cardColor = newValue.cardColor
        date = newValue.date
        return self
    }
    
    func asNotableResponse(with status: HTTPResponseStatus, error: ErrorMessage?) -> NoteResponse<Note> {
        .init(code: status, error: error, data: self)
    }
    
}

