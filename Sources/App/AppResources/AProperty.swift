//
//  AProperty.swift
//  NotesKit
//
//  Created by Darshan S on 11/01/25.
//

import Foundation
import Fluent

public class AProperty<Item: SortableGenericItem, Value: SortableItem.AProperAssociatedObject>: Comparable {
    
    public var value: Value?
    
    public var wrappedValue: Value? {
        value
    }
    
    public init(wrappedValue: Value) {
        self.value = wrappedValue
    }
    
    public static func < (lhs: AProperty, rhs: AProperty) -> Bool {
        if let lhsValue = lhs.value,let rhsValue = rhs.value {
            return lhsValue < rhsValue
        }
        return false
    }
    
    public static func == (lhs: AProperty, rhs: AProperty) -> Bool {
        lhs.value == rhs.value
    }
}
