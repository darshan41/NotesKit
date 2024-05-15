//
//  Profile.swift
//
//
//  Created by Darshan S on 15/05/24.
//

import Vapor
import Fluent

final class Profile: SortableItem,@unchecked Sendable {
    
    typealias SortingValue = Date
    typealias FilteringValue = Date
    
    typealias T = FieldProperty<Profile, SortingValue>
    typealias U = FieldProperty<Profile, SortingValue>
    
    
    static let schema = "profiles"
    
    static let profileName: FieldKey = FieldKey("profileName")
    static let profileImage: FieldKey = FieldKey("profileImage")
    static let createdDate: FieldKey = FieldKey("createdDate")
    static let updatedDate: FieldKey = FieldKey("updatedDate")
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: Profile.profileName)
    var profileName: String
    
    @Field(key: Profile.profileImage)
    var profileImage: String
    
    @Field(key: createdDate)
    var createdDate: Date
    
    @Field(key: updatedDate)
    var updatedDate: Date
    
    
    init() { }
    
    init(profileName: String,profileImage: String,updatedDate: Date?,createdDate: Date?) {
        self.profileImage = profileImage
        self.profileName = profileName
        self.createdDate = createdDate ?? Date()
        self.updatedDate = updatedDate ?? Date()
    }
 
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id)
        self.profileName = try container.decode(String.self, forKey: .profileName)
        self.profileImage = (try? container.decode(String.self, forKey: .profileName)) ?? ""
        self.createdDate = Date()
        self.updatedDate = Date()
    }
}

extension Profile {
    
    var someComparable: FluentKit.FieldProperty<Profile, SortingValue> { self.$createdDate }
    
    var filterSearchItem: FluentKit.FieldProperty<Profile, SortingValue> { self.$createdDate }
    
    func requestUpdate(with newValue: Profile) -> Profile {
        return self
    }
    
    func asNotableResponse(with status: HTTPResponseStatus, error: ErrorMessage?) -> AppResponse<Profile> {
        .init(code: status, error: error, data: self)
    }
}

extension Profile: Comparable {
    
    enum CodingKeys: String,CodingKey,Codable {
        case id
        case profileImage
        case profileName
//        case createdDate
//        case updatedDate
    }
    
    static func < (lhs: Profile, rhs: Profile) -> Bool {
        lhs.updatedDate < rhs.updatedDate
    }
    
    static func == (lhs: Profile, rhs: Profile) -> Bool {
        lhs.id == rhs.id
    }
}

