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
    var name: Name
    
    @Field(key: userName)
    var userName: UserName
    
    @Field(key: email)
    var email: Email
    
    @Field(key: phone)
    var phone: PhoneNumber
    
    @Children(for: \.$user)
    var notes: [Note]
    
    @Field(key: zipcode)
    var zipcode: ZipCode
    
    @Field(key: countryCode)
    var countryCode: CountryCode
    
    @Field(key: createdDate)
    var createdDate: Date
    
    @Field(key: updatedDate)
    var updatedDate: Date
    
    init() { }
    
    init(
        id: UUID? = nil,
        name: Name,
        userName: UserName,
        email: Email,
        phone: PhoneNumber,
        zipcode: ZipCode,
        countryCode: CountryCode,
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
        self.name = try container.decode(Name.self, forKey: .name)
        self.userName = try container.decode(UserName.self, forKey: .userName)
        self.email = try container.decode(Email.self, forKey: .email)
        self.phone = try container.decode(PhoneNumber.self, forKey: .phone)
        self.zipcode = try container.decode(ZipCode.self, forKey: .zipcode)
        self.countryCode = try container.decode(CountryCode.self, forKey: .countryCode)
        self.createdDate = Date()
        self.updatedDate = Date()
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(UserDTO(user: self), forKey: .user)
    }
}

extension User {
    
    struct UserDTO: Codable,Content {
        let id: User.IDValue?
        let name: Name
        let userName: UserName
        let email: Email
        let phone: PhoneNumber
        let zipcode: ZipCode
        let countryCode: CountryCode
        let createdDate: Date
        let updatedDate: Date
        
        init(user: User) {
            self.id = user.id
            self.name = user.name
            self.userName = user.userName
            self.email = user.email
            self.phone = user.phone
            self.zipcode = user.zipcode
            self.countryCode = user.countryCode
            self.createdDate = user.createdDate
            self.updatedDate = user.updatedDate
        }
    }
    
    fileprivate enum CodingKeys: String,CodingKey {
        case name
        case id
        case userName
        case email
        case phone
        case user
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
        self.updatedDate = Date()
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


