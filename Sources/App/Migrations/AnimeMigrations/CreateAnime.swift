//
//  CreateAnime.swift
//
//
//  Created by Darshan S on 14/07/24.
//

import Foundation
import Fluent

struct CreateAnime: AppMigration {
    
    typealias MigraterModelClass = Note
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Anime.schema)
            .id()
            .field(Anime.originalURL, .string, .required)
            .field(Anime.titleRegexs, .array(of: .string), .required)
            .field(Anime.date, .date, .required)
            .field(Anime.seasonRegexs,.array(of: .string),.required)
            .field(Anime.episodeRegexs,.array(of: .string),.required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Anime.schema).delete()
    }
}

