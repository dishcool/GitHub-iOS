//
//  RepositoryServiceProtocol.swift
//  GitHub
//
//  Created by Dishcool on 2025/5/15.
//

import Foundation

protocol RepositoryServiceProtocol {
    func getTrendingRepositories(language: String?, timeSpan: String?, useCache: Bool, completion: @escaping (Result<[Repository], Error>) -> Void)
    func getRepositoriesForUser(username: String, page: Int, perPage: Int, useCache: Bool, completion: @escaping (Result<[Repository], Error>) -> Void)
    func getRepositoryDetails(owner: String, name: String, useCache: Bool, completion: @escaping (Result<Repository, Error>) -> Void)
    func searchRepositories(query: String, page: Int, perPage: Int, useCache: Bool, completion: @escaping (Result<[Repository], Error>) -> Void)
    func fetchRepositoryReadme(owner: String, name: String, completion: @escaping (Result<String, Error>) -> Void)
    
    // Clear all caches
    func clearCache()
    // Clear a specific type of cache
    func clearCache(forType: CacheType)
}

// Cache type enumeration
enum CacheType {
    case trending
    case userRepositories(username: String)
    case repositoryDetails(owner: String, name: String)
    case search(query: String)
} 