//
//  User.swift
//  GitHub
//
//  Created by Dishcool on 2025/5/15.
//

import Foundation

/// Model representing a GitHub user
struct User: Identifiable, Codable, Equatable {
    let id: Int
    let login: String
    let avatarUrl: String
    let name: String?
    let bio: String?
    let email: String?
    let location: String?
    let followers: Int?
    let following: Int?
    let publicRepos: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case login
        case avatarUrl = "avatar_url"
        case name
        case bio
        case email
        case location
        case followers
        case following
        case publicRepos = "public_repos"
    }
    
    // Implement Equatable - two users are the same if they have the same id
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
}

extension User {
    static var placeholder: User {
        User(
            id: 0,
            login: "github",
            avatarUrl: "https://avatars.githubusercontent.com/u/9919?v=4",
            name: "GitHub",
            bio: "How people build software.",
            email: "support@github.com",
            location: "San Francisco, CA",
            followers: 10000,
            following: 0,
            publicRepos: 300
        )
    }
} 
