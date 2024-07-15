//
//  Atomic.swift
//  
//
//  Created by Darshan S on 16/07/24.
//

import Foundation

@propertyWrapper
struct Atomic<Value> {

    private let lock = NSLock()
    private var value: Value

    init(default: Value) {
        self.value = `default`
    }

    var wrappedValue: Value {
        get {
            lock.lock()
            defer { lock.unlock() }
            return value
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            value = newValue
        }
    }
}
