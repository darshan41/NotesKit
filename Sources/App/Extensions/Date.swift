//
//  Date.swift
//  
//
//  Created by Darshan S on 15/05/24.
//

import Foundation

public extension Date {
    
    init(timeIntervalSince1970: Double?) {
        self.init(timeIntervalSince1970: timeIntervalSince1970 ?? Date.now.timeIntervalSince1970)
    }
    
}
