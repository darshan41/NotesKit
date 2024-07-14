//
//  User.swift
//
//
//  Created by Darshan S on 15/05/24.
//

import Vapor
import Fluent

final class User: SortableItem,@unchecked Sendable,Encodable {
    
    static let schema = "users"
    
    typealias T = FieldProperty<User, SortingValue>
    typealias U = FieldProperty<User, FilteringValue>
    
    typealias SortingValue = FilteringValue
    typealias FilteringValue = Date
    
    static let name: FieldKey = FieldKey("name")
    static let userName: FieldKey = FieldKey("userName")
    static let email:  FieldKey = FieldKey("email")
    static let phone: FieldKey = FieldKey("phone")
    static let zipcode: FieldKey = FieldKey("zipcode")
    static let countryCode: FieldKey = FieldKey("countryCode")
    static let createdDate: FieldKey = FieldKey("createdDate")
    static let updatedDate: FieldKey = FieldKey("updatedDate")
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: name)
    var name: String
    
    @Field(key: userName)
    var userName: String
    
    @Field(key: email)
    var email: Email
    
    @Field(key: phone)
    var phone: String
    
    @Field(key: zipcode)
    var zipcode: String
    
    @Field(key: countryCode)
    var countryCode: String
    
    @Field(key: createdDate)
    var createdDate: Date
    
    @Field(key: updatedDate)
    var updatedDate: Date
    
    init() { }
    
    init(
        id: UUID? = nil,
        name: String,
        userName: String,
        email: Email,
        phone: String,
        zipcode: String,
        countryCode: String,
        createdDate: Date?,
        updatedDate: Date?
    ) {
        self.name = name
        self.userName = userName
        self.email = email
        self.phone = phone
        self.zipcode = zipcode
        self.countryCode = countryCode
        self.createdDate = createdDate ?? Date()
        self.updatedDate = updatedDate ?? Date()
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.userName = try container.decode(String.self, forKey: .userName)
        self.email = try container.decode(Email.self, forKey: .email)
        self.phone = try container.decode(String.self, forKey: .phone)
        self.zipcode = try container.decode(String.self, forKey: .zipcode)
        self.countryCode = try container.decode(String.self, forKey: .countryCode)
        self.createdDate = Date()
        self.updatedDate = Date()
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
    }
}

extension User {
    
    fileprivate enum CodingKeys: String,CodingKey {
        case name
        case id
        case userName
        case email
        case phone
        case zipcode
        case countryCode
        case createdDate
        case updatedDate
    }
    
    var someComparable: FluentKit.FieldProperty<User, SortingValue> { self.$updatedDate }
    
    var filterSearchItem: FluentKit.FieldProperty<User, FilteringValue> { self.$updatedDate }
    
    func requestUpdate(with newValue: User) -> User {
        self.name = newValue.name
        self.countryCode = newValue.countryCode
        self.zipcode = newValue.zipcode
        self.phone = newValue.phone
        self.email = newValue.email
        self.userName = newValue.userName
        return self
    }
    
    func asNotableResponse(with status: HTTPResponseStatus, error: ErrorMessage?) -> AppResponse<User> {
        .init(code: status, error: error, data: self)
    }
}


extension User: Comparable {
    
    static func < (lhs: User, rhs: User) -> Bool {
        lhs.updatedDate < rhs.updatedDate
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
}


