//
//  Helpers.swift
//  
//
//  Created by Darshan S on 17/05/24.
//

import Foundation

extension Dictionary<String,String> {
    
    var intified: [Dictionary<Int, String>.Element] {
        self.compactMap { dict -> Dictionary<Int,String>.Element? in
            guard let intified = Int(dict.key) else { return nil }
            return Dictionary<Int,String>.Element(key: intified, value: dict.value)
        }
    }
    
    var sortedOnKeys: [Dictionary<String, String>.Element] {
        self.sorted(by: { $0.key < $1.key })
    }
    
    var stringifiedJoinedByLineBreakSeperator: String {
        map({ $0.key + " " + $0.value }).joined(separator: "\n")
    }
    
    var sortedOnKeysJoinedTogetherByValue: [String] {
        sortedOnKeys.map { $0.key + " " + $0.value }
    }
}

extension Array where Element == Dictionary<Int,String>.Element {
    
    var intiSorted: [Dictionary<Int, String>.Element] {
        sorted(by: { $0.key < $1.key })
    }
}
