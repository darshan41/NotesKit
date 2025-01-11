//
//  File.swift
//  NotesKit
//
//  Created by Darshan S on 11/01/25.
//

import Foundation
import Fluent

public struct AProperty<Item: SortableGenericItem, Value: SortableItem.AProperAssociatedObject>: Comparable {
    
    var value: Value
    
    public var wrappedValue: Value {
        value
    }
    
    public init(wrappedValue: Value) {
        self.value = wrappedValue
    }
    
    public static func < (lhs: AProperty, rhs: AProperty) -> Bool {
        lhs.value < rhs.value
    }
    
    public static func == (lhs: AProperty, rhs: AProperty) -> Bool {
        lhs.value == rhs.value
    }
}
