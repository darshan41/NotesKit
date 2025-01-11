//
//  AppContentDecoder.swift
//
//
//  Created by Darshan S on 19/05/24.
//

import Vapor
import Fluent

public class AppContentDecoder: JSONDecoder, @unchecked Sendable {
    
    public override func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        do {
            return try super.decode(type, from: data)
        } catch {
            throw error.asErrorShowble
        }
    }
}
