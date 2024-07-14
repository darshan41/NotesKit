//
//  Anime.swift
//
//
//  Created by Darshan S on 11/05/24.
//

import Vapor
import Fluent

final class Anime: Notable,@unchecked Sendable {
    
    typealias T = FieldProperty<Anime, SortingValue>
    typealias U = FieldProperty<Anime, FilteringValue>
    
    typealias SortingValue = Date
    typealias FilteringValue = URL
    
    static let schema = "anime"
    
    static let date: FieldKey = FieldKey("date")
    static let originalURL: FieldKey = FieldKey("originalURL")
    static let titleRegexs: FieldKey = FieldKey("titleRegexs")
    static let seasonRegexs: FieldKey = FieldKey("seasonRegexs")
    static let episodeRegexs: FieldKey = FieldKey("episodeRegexs")
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: originalURL)
    var originalURL: URL
    
    @Field(key: titleRegexs)
    var titleRegexs: [String]
    
    @Field(key: episodeRegexs)
    var episodeRegexs: [String]
    
    @Field(key: seasonRegexs)
    var seasonRegexs: [String]
    
    @Field(key: date)
    var date: Date
    
    init() { }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let originalURL = try container.decode(URL.self, forKey: .originalURL)
        self.originalURL = originalURL
        self.id = try container.decodeIfPresent(IDValue.self, forKey: .id)
        self.titleRegexs = try container.decode([String].self, forKey: .titleRegexs)
        self.seasonRegexs = try container.decode([String].self, forKey: .seasonRegexs)
        self.episodeRegexs = try container.decode([String].self, forKey: .episodeRegexs)
        _ = try self.getAnimeInfoDomainObject
        self.date = Date()
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(titleRegexs, forKey: .titleRegexs)
        try container.encode(seasonRegexs, forKey: .seasonRegexs)
        try container.encode(episodeRegexs, forKey: .episodeRegexs)
        try container.encode(originalURL, forKey: .originalURL)
        try container.encode(try? self.getAnimeInfoDomainObject, forKey: .animeInfo)
        try container.encode(date, forKey: .date)
    }
    
    fileprivate enum CodingKeys: String,CodingKey {
        case id
        case titleRegexs
        case originalURL
        case date
        case episodeRegexs
        case animeInfo
        case seasonRegexs
    }
    
    var someComparable: FluentKit.FieldProperty<Anime, Date> { self.$date }
    var filterSearchItem: FluentKit.FieldProperty<Anime, URL> { self.$originalURL }
}

extension Anime {
    
    func requestUpdate(with newValue: Anime) -> Anime {
        originalURL = newValue.originalURL
        titleRegexs = newValue.titleRegexs
        seasonRegexs = newValue.seasonRegexs
        episodeRegexs = newValue.episodeRegexs
        date = newValue.date
        return self
    }
    
    func asNotableResponse(with status: HTTPResponseStatus, error: ErrorMessage?) -> AppResponse<Anime> {
        .init(code: status, error: error, data: self)
    }
}

extension Anime: Comparable {
    
    private static func pathValidator(for url: URL) throws -> String {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        guard components?.scheme == "https",components?.path != nil,components?.path != "",components?.path != "/" else {
            throw AnimeInfoConstructError.custom(errorString: "Path Validation Failure")
        }
        return components!.path
    }
    
    static func < (lhs: Anime, rhs: Anime) -> Bool {
        lhs.date > rhs.date
    }
    
    static func == (lhs: Anime, rhs: Anime) -> Bool {
        lhs.id == rhs.id
    }
    
    var getAnimeInfoDomainObject: AnimeURI {
        get throws {
            try AnimeURI(from: self.originalURL, urlPathValidation: Anime.pathValidator(for:), titleRegexs: Set(titleRegexs), seasonRegexs: Set(seasonRegexs), episodeRegexs: Set(episodeRegexs))
        }
    }
}


extension URL: Sendable { }


extension Anime {
    
    struct AnimeURI: Codable {
        var url: URL
        var title: String
        var season: String
        var episode: String
        
        init(
            from url: URL,
            urlPathValidation: ((URL) throws -> String),
            titleRegexs: Set<String>,
            seasonRegexs: Set<String>,
            episodeRegexs: Set<String>
        ) throws {
            self.url = url
            let path = try urlPathValidation(url)
            self.episode = (try? RegexOpertor(pathComponent: path, regexSets: episodeRegexs).executeRegexSets(thrownErrorString: "Episode Regex has failed")) ?? "NA, Latest Episode Cant be recorded"
            self.season = (try? RegexOpertor(pathComponent: path, regexSets: seasonRegexs).executeRegexSets(thrownErrorString: "Season Regex has Failed")) ?? "NA, Latest Season Cant be recorded"
            self.title = try RegexOpertor(pathComponent: path, regexSets: titleRegexs).executeRegexSets(thrownErrorString: "Title Regex Has Failed",successMappedString: { value in
                return value.replacingOccurrences(of: "-", with: " ").capitalized
            })
        }
    }


    public enum AnimeInfoConstructError: Error {
        
        public var isUserShowableErrorMessage: Bool { true }
        
        public var identifier: String {
            return "\(Self.self)"
        }
        
        public var reason: String {
            switch self {
            case .custom(let errorString):
                return errorString
            }
        }
        
        case custom(errorString: String)
    }

    struct URLPath: Codable {
        let path: String
    }


    struct RegexOpertor {
        
        private let urlPathComponent: String
        private let regexSets: Set<String>
        
        init(pathComponent: String,regexSets: Set<String>) throws {
            self.urlPathComponent = pathComponent
            self.regexSets = regexSets
        }
        
        func executeRegexSets(thrownErrorString: String,successMappedString: ((String) -> (String))? = nil) throws -> String {
            for regexSet in regexSets {
                guard let titleRange = urlPathComponent.range(of: regexSet, options: .regularExpression) else {
                    continue
                }
                let evaluetedValue = String(urlPathComponent[titleRange])
                if let successMappedString {
                    return successMappedString(evaluetedValue)
                } else {
                    return evaluetedValue
                }
            }
            throw AnimeInfoConstructError.custom(errorString: thrownErrorString)
        }
        
    }
}
