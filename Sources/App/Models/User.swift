//
//  User.swift
//
//
//  Created by Darshan S on 15/05/24.
//

import Vapor
import Fluent

final class User: Modelable,@unchecked Sendable {
    
    static let schema = "users"
    static let name: FieldKey = FieldKey("name")
    static let userName: FieldKey = FieldKey("userName")
    static let email:  FieldKey = FieldKey("email")
    static let phone: FieldKey = FieldKey("phone")
    static let zipcode: FieldKey = FieldKey("zipcode")
    static let countryCode: FieldKey = FieldKey("countryCode")
    
    @ID
    var id: UUID?
    
    @Field(key: name)
    var name: String
    
    @Field(key: userName)
    var userName: String
    
    @Field(key: email)
    var email: String
    
    @Field(key: phone)
    var phone: String
    
    @Field(key: zipcode)
    var zipcode: String
    
    @Field(key: countryCode)
    var countryCode: String
    
    init() { }
    
    init(
        id: UUID? = nil,
        name: String,
        userName: String,
        email: String,
        phone: String,
        zipcode: String,
        countryCode: String
    ) {
        self.name = name
        self.userName = userName
        self.email = email
        self.phone = phone
        self.zipcode = zipcode
        self.countryCode = countryCode
    }
}

extension User {
        
    func requestUpdate(with newValue: User) -> User {
        return self
    }
    
    func asNotableResponse(with status: HTTPResponseStatus, error: ErrorMessage?) -> AppResponse<User> {
        .init(code: status, error: error, data: self)
    }
}
