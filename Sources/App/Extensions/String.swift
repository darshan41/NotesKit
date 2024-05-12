//
//  String.swift
//  
//
//  Created by Darshan S on 12/05/24.
//

import Foundation


extension String {
    
    static var id: String { "id" }
    
}


extension String? {
    
    var uuid: UUID? {
        guard let self else { return nil }
        return UUID(uuidString: self)
    }
    
    func getCastedTID<T: Notable>(_ t: T.Type = T.self) -> T.IDValue? {
        uuid as? T.IDValue
    }
}
