//
//  Parameters.swift
//
//
//  Created by Darshan S on 12/05/24.
//

import Vapor
import Foundation
import Fluent

extension Parameters {
    
    func getCastedTID<T: Notable>(_ t: T.Type = T.self) -> T.IDValue? {
        self.get(.id, as: String.self).uuid as? T.IDValue
    }
}

