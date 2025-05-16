//
//  Repository.swift
//  GitHub
//
//  Created by Dishcool on 2025/5/15.
//

import Foundation

/// Model representing a GitHub repository
struct Repository: Identifiable, Codable, Equatable {
    let id: Int
    let name: String
    let fullName: String
    let owner: User
    let description: String?
    let isPrivate: Bool
    let htmlUrl: URL
    let createdAt: Date
    let updatedAt: Date
    let pushedAt: Date?
    let size: Int
    let stargazersCount: Int
    let watchersCount: Int
    let language: String?
    let forksCount: Int
    let openIssuesCount: Int
    let license: License?
    
    static func == (lhs: Repository, rhs: Repository) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func placeholder(number: Int = 1) -> Repository {
        return Repository(
            id: number,
            name: "sample-repo-\(number)",
            fullName: "user/sample-repo-\(number)",
            owner: User.placeholder,
            description: "This is a sample repository for testing purposes",
            isPrivate: false,
            htmlUrl: URL(string: "https://github.com/user/sample-repo-\(number)")!,
            createdAt: Date(),
            updatedAt: Date(),
            pushedAt: Date(),
            size: 123,
            stargazersCount: 10 * number,
            watchersCount: 5 * number,
            language: "Swift",
            forksCount: 3 * number,
            openIssuesCount: 2 * number,
            license: License.placeholder()
        )
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case fullName = "full_name"
        case owner
        case description
        case isPrivate = "private"
        case htmlUrl = "html_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case pushedAt = "pushed_at"
        case size
        case stargazersCount = "stargazers_count"
        case watchersCount = "watchers_count"
        case language
        case forksCount = "forks_count"
        case openIssuesCount = "open_issues_count"
        case license
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode basic fields
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        fullName = try container.decode(String.self, forKey: .fullName)
        owner = try container.decode(User.self, forKey: .owner)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        isPrivate = try container.decode(Bool.self, forKey: .isPrivate)
        htmlUrl = try container.decode(URL.self, forKey: .htmlUrl)
        size = try container.decode(Int.self, forKey: .size)
        stargazersCount = try container.decode(Int.self, forKey: .stargazersCount)
        watchersCount = try container.decode(Int.self, forKey: .watchersCount)
        language = try container.decodeIfPresent(String.self, forKey: .language)
        forksCount = try container.decode(Int.self, forKey: .forksCount)
        openIssuesCount = try container.decode(Int.self, forKey: .openIssuesCount)
        license = try container.decodeIfPresent(License.self, forKey: .license)
        
        // Use custom ISO8601 date decoder to handle date strings
        let dateFormatter = ISO8601DateFormatter()
        
        // Decode createdAt
        if let createdAtString = try container.decodeIfPresent(String.self, forKey: .createdAt),
           let date = dateFormatter.date(from: createdAtString) {
            createdAt = date
        } else {
            createdAt = Date.distantPast
        }
        
        // Decode updatedAt
        if let updatedAtString = try container.decodeIfPresent(String.self, forKey: .updatedAt),
           let date = dateFormatter.date(from: updatedAtString) {
            updatedAt = date
        } else {
            updatedAt = Date.distantPast
        }
        
        // Decode optional pushedAt
        if let pushedAtString = try container.decodeIfPresent(String.self, forKey: .pushedAt),
           let date = dateFormatter.date(from: pushedAtString) {
            pushedAt = date
        } else {
            pushedAt = nil
        }
    }
    
    // Manual initializer to support the placeholder method
    init(id: Int, name: String, fullName: String, owner: User, description: String?, isPrivate: Bool, htmlUrl: URL, createdAt: Date, updatedAt: Date, pushedAt: Date?, size: Int, stargazersCount: Int, watchersCount: Int, language: String?, forksCount: Int, openIssuesCount: Int, license: License?) {
        self.id = id
        self.name = name
        self.fullName = fullName
        self.owner = owner
        self.description = description
        self.isPrivate = isPrivate
        self.htmlUrl = htmlUrl
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.pushedAt = pushedAt
        self.size = size
        self.stargazersCount = stargazersCount
        self.watchersCount = watchersCount
        self.language = language
        self.forksCount = forksCount
        self.openIssuesCount = openIssuesCount
        self.license = license
    }
}

/// Model representing a GitHub repository license
struct License: Codable, Equatable {
    let key: String
    let name: String
    let spdxId: String?
    let url: URL?
    
    static func placeholder() -> License {
        return License(
            key: "mit",
            name: "MIT License",
            spdxId: "MIT",
            url: URL(string: "https://api.github.com/licenses/mit")
        )
    }
    
    enum CodingKeys: String, CodingKey {
        case key
        case name
        case spdxId = "spdx_id"
        case url
    }
    
    // Add manual initializer to support placeholder
    init(key: String, name: String, spdxId: String?, url: URL?) {
        self.key = key
        self.name = name
        self.spdxId = spdxId
        self.url = url
    }
} 
