//
//  AppDecoder.swift
//
//
//  Created by Darshan S on 12/05/24.
//

import Foundation

open class AppDecoder: @unchecked Sendable {
    
    public static let shared: AppDecoder = AppDecoder()
    
    public lazy var iso8601JSONDeocoder = {
        let decoder = AppContentDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}
