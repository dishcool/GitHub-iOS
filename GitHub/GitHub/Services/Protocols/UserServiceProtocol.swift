//
//  UserServiceProtocol.swift
//  GitHub
//
//  Created by Dishcool on 2025/5/15.
//

import Foundation

protocol UserServiceProtocol {
    func getUserProfile(username: String, completion: @escaping (Result<User, Error>) -> Void)
    func searchUsers(query: String, page: Int, perPage: Int, completion: @escaping (Result<[User], Error>) -> Void)
} 