//
//  Organization.swift
//  GitHub
//
//  Created by Dishcool on 2025/5/15.
//

import Foundation

/// 代表GitHub组织的模型
struct Organization: Identifiable, Codable {
    let id: Int
    let login: String
    let avatarUrl: String
    let name: String?
    let description: String?
    let location: String?
    let email: String?
    let blog: String?
    let publicRepos: Int
    let followers: Int?
    let following: Int?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case login
        case avatarUrl = "avatar_url"
        case name
        case description
        case location
        case email
        case blog
        case publicRepos = "public_repos"
        case followers
        case following
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

extension Organization {
    static var placeholder: Organization {
        Organization(
            id: 1,
            login: "apple",
            avatarUrl: "https://avatars.githubusercontent.com/u/10639145?v=4",
            name: "Apple",
            description: "Apple Inc.",
            location: "Cupertino, CA",
            email: nil,
            blog: "https://developer.apple.com",
            publicRepos: 100,
            followers: nil,
            following: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
} 