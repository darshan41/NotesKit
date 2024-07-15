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
    
    func getCastedTID<T: Modelable>(_ t: T.Type = T.self) -> T.IDValue? {
        self.get(.id, as: String.self).uuid as? T.IDValue
    }
}

extension Array {
    
    func byAdding(_ component: Element...) -> [Element] {
        self + component
    }
    
    mutating
    func byAdding(_ components: [Element]) -> Self {
        self + components
    }
}

public extension FieldKey {
    
     init(_ keyStringValue: String) {
        self.init(stringLiteral: keyStringValue)
    }
}
