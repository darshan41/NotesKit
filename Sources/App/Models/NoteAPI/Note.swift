//
//  Note.swift
//
//
//  Created by Darshan S on 11/05/24.
//

import Vapor
import Fluent

protocol CustomEncodable { }

final class Note: SortableItem, @unchecked Sendable {
    
    typealias T = FieldProperty<Note, SortingValue>
    typealias U = FieldProperty<Note, FilteringValue>
    
    struct RequestDTO: Codable {
        private(set) var id: UUID?
        private(set) var note: String
        private(set) var user: User.IDValue?
        private(set) var cardColor: String
        
        init(from decoder: any Decoder) throws {
            let container: KeyedDecodingContainer<Note.RequestDTO.CodingKeys> = try decoder.container(keyedBy: Note.RequestDTO.CodingKeys.self)
            self.id = try container.decodeIfPresent(UUID.self, forKey: Note.RequestDTO.CodingKeys.id)
            self.note = try container.decode(String.self, forKey: Note.RequestDTO.CodingKeys.note)
            self.user = try container.decodeIfPresent(User.IDValue.self, forKey: Note.RequestDTO.CodingKeys.user)
            self.cardColor = try container.decode(String.self, forKey: Note.RequestDTO.CodingKeys.cardColor)
        }
    }
    
    typealias SortingValue = Date
    typealias FilteringValue = String
    
    static let schema = "notes"
    static let objectIdentifierKey: String = "noteID"
    
    static let date: FieldKey = FieldKey("date")
    static let note: FieldKey = FieldKey("note")
    static let cardColor: FieldKey = FieldKey("cardColor")
    static let userId: FieldKey = FieldKey("userId")
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: note)
    var note: String
    
    @Parent(key: userId)
    var user: User
    
    @Field(key: cardColor)
    var cardColor: String
    
    @Field(key: date)
    var date: Date
    
    @Siblings(
        through: NoteCategoryPivot.self,
        from: \.$note,
        to: \.$category)
    var categories: [Category]
    
    init() { }
    
    init(requestDto: RequestDTO,userId: User.IDValue) {
        self.id = requestDto.id
        self.cardColor = requestDto.cardColor
        self.note = requestDto.note
        self.$user.id = userId
        self.date = Date()
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(IDValue.self, forKey: .id)
        self.cardColor = try container.decode(String.self, forKey: .cardColor)
        self.note = try container.decode(String.self, forKey: .note)
        self.$user.id = try container.decode(IDValue.self, forKey: .userId)
        self.date = Date()
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(cardColor, forKey: .cardColor)
        try container.encode(note, forKey: .note)
        try container.encode($user.id, forKey: .userId)
        try container.encode(date, forKey: .date)
    }
    
    init(
        id: UUID? = nil,
        note: String,
        cardColor: String,
        date: Date,
        userID: User.IDValue
    ) {
        self.id = id
        self.cardColor = cardColor
        self.note = note
        self.date = date
        self.$user.id = userID
    }
    
    fileprivate enum CodingKeys: String,CodingKey {
        case id
        case cardColor
        case note
        case date
        case user
        case userId
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
        lhs.date > rhs.date
    }
    
    static func == (lhs: Note, rhs: Note) -> Bool {
        lhs.id == rhs.id
    }
}
