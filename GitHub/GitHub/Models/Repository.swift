//
//  Repository.swift
//  GitHub
//
//  Created by Dishcool on 2025/5/15.
//

import Foundation

/// 代表GitHub仓库的模型
struct Repository: Identifiable, Codable {
    let id: Int
    let name: String
    let fullName: String
    let owner: User
    let isPrivate: Bool
    let description: String?
    let fork: Bool
    let language: String?
    let forksCount: Int
    let stargazersCount: Int
    let watchersCount: Int
    let openIssuesCount: Int
    let defaultBranch: String
    let createdAt: Date
    let updatedAt: Date
    let pushedAt: Date?
    let htmlUrl: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case fullName = "full_name"
        case owner
        case isPrivate = "private"
        case description
        case fork
        case language
        case forksCount = "forks_count"
        case stargazersCount = "stargazers_count"
        case watchersCount = "watchers_count"
        case openIssuesCount = "open_issues_count"
        case defaultBranch = "default_branch"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case pushedAt = "pushed_at"
        case htmlUrl = "html_url"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // 解码基本字段
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        fullName = try container.decode(String.self, forKey: .fullName)
        owner = try container.decode(User.self, forKey: .owner)
        isPrivate = try container.decode(Bool.self, forKey: .isPrivate)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        fork = try container.decode(Bool.self, forKey: .fork)
        language = try container.decodeIfPresent(String.self, forKey: .language)
        forksCount = try container.decode(Int.self, forKey: .forksCount)
        stargazersCount = try container.decode(Int.self, forKey: .stargazersCount)
        watchersCount = try container.decode(Int.self, forKey: .watchersCount)
        openIssuesCount = try container.decode(Int.self, forKey: .openIssuesCount)
        defaultBranch = try container.decode(String.self, forKey: .defaultBranch)
        htmlUrl = try container.decode(String.self, forKey: .htmlUrl)
        
        // 使用自定义ISO8601日期解码器处理日期字符串
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        // 解码createdAt
        let createdAtString = try container.decode(String.self, forKey: .createdAt)
        if let date = dateFormatter.date(from: createdAtString) {
            createdAt = date
        } else {
            let fallbackFormatter = ISO8601DateFormatter()
            if let date = fallbackFormatter.date(from: createdAtString) {
                createdAt = date
            } else {
                throw DecodingError.dataCorruptedError(
                    forKey: .createdAt,
                    in: container,
                    debugDescription: "Date string does not match expected format: \(createdAtString)"
                )
            }
        }
        
        // 解码updatedAt
        let updatedAtString = try container.decode(String.self, forKey: .updatedAt)
        if let date = dateFormatter.date(from: updatedAtString) {
            updatedAt = date
        } else {
            let fallbackFormatter = ISO8601DateFormatter()
            if let date = fallbackFormatter.date(from: updatedAtString) {
                updatedAt = date
            } else {
                throw DecodingError.dataCorruptedError(
                    forKey: .updatedAt,
                    in: container,
                    debugDescription: "Date string does not match expected format: \(updatedAtString)"
                )
            }
        }
        
        // 解码可选的pushedAt
        if let pushedAtString = try container.decodeIfPresent(String.self, forKey: .pushedAt) {
            if let date = dateFormatter.date(from: pushedAtString) {
                pushedAt = date
            } else {
                let fallbackFormatter = ISO8601DateFormatter()
                pushedAt = fallbackFormatter.date(from: pushedAtString)
            }
        } else {
            pushedAt = nil
        }
    }
}

/// 代表GitHub仓库许可证的模型
struct License: Codable {
    let key: String
    let name: String
    let url: URL?
    let spdxId: String?
    
    enum CodingKeys: String, CodingKey {
        case key
        case name
        case url
        case spdxId = "spdx_id"
    }
}

extension Repository {
    static var placeholder: Repository {
        Repository(
            id: 1,
            name: "swift",
            fullName: "apple/swift",
            owner: User.placeholder,
            isPrivate: false,
            description: "The Swift Programming Language",
            fork: false,
            language: "C++",
            forksCount: 9000,
            stargazersCount: 60000,
            watchersCount: 3000,
            openIssuesCount: 500,
            defaultBranch: "main",
            createdAt: Date(),
            updatedAt: Date(),
            pushedAt: Date(),
            htmlUrl: "https://github.com/apple/swift"
        )
    }
    
    // 添加手动初始化方法，以支持placeholder
    init(
        id: Int,
        name: String,
        fullName: String,
        owner: User,
        isPrivate: Bool,
        description: String?,
        fork: Bool,
        language: String?,
        forksCount: Int,
        stargazersCount: Int,
        watchersCount: Int,
        openIssuesCount: Int,
        defaultBranch: String,
        createdAt: Date,
        updatedAt: Date,
        pushedAt: Date?,
        htmlUrl: String
    ) {
        self.id = id
        self.name = name
        self.fullName = fullName
        self.owner = owner
        self.isPrivate = isPrivate
        self.description = description
        self.fork = fork
        self.language = language
        self.forksCount = forksCount
        self.stargazersCount = stargazersCount
        self.watchersCount = watchersCount
        self.openIssuesCount = openIssuesCount
        self.defaultBranch = defaultBranch
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.pushedAt = pushedAt
        self.htmlUrl = htmlUrl
    }
} 