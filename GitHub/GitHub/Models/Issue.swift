//
//  Issue.swift
//  GitHub
//
//  Created by Dishcool on 2025/5/21.
//

import Foundation

struct Issue: Identifiable, Codable {
    let id: Int
    let number: Int
    let title: String
    let body: String?
    let state: String
    let createdAt: String
    let updatedAt: String
    let comments: Int
    let user: User
    let labels: [Label]?
    let assignees: [User]?
    
    enum CodingKeys: String, CodingKey {
        case id, number, title, body, state, comments, user, labels, assignees
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct Label: Identifiable, Codable {
    let id: Int
    let name: String
    let color: String
    let description: String?
} 