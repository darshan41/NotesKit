//
//  AppDecoder.swift
//
//
//  Created by Darshan S on 12/05/24.
//

import Foundation

open class AppDecoder: @unchecked Sendable {
    
    static let shared: AppDecoder = AppDecoder()
    
    lazy var iso8601JSONDeocoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}
