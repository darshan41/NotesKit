//
//  Profile.swift
//
//
//  Created by Darshan S on 15/05/24.
//

import Vapor
import Fluent

final class Profile: Modelable,@unchecked Sendable {
    
    static let schema = "profiles"
    
    static let profileName: FieldKey = FieldKey("profileName")
    static let profileImage: FieldKey = FieldKey("profileImage")
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: Profile.profileName)
    var profileName: String
    
    @Field(key: Profile.profileImage)
    var profileImage: String
    
    init() { }
     
}

extension Profile {
        
    func requestUpdate(with newValue: Profile) -> Profile {
        return self
    }
    
    func asNotableResponse(with status: HTTPResponseStatus, error: ErrorMessage?) -> AppResponse<Profile> {
        .init(code: status, error: error, data: self)
    }
}
