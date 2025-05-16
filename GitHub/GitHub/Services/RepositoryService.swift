//
//  RepositoryService.swift
//  GitHub
//
//  Created by Dishcool on 2025/5/15.
//

import Foundation

// Removed typealias and directly use NetworkServiceProtocol

class RepositoryService: RepositoryServiceProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    public func getTrendingRepositories(language: String? = nil, timeSpan: String? = nil, useCache: Bool = true, completion: @escaping (Result<[Repository], Error>) -> Void) {
        // Build query string
        var query = "stars:>100"
        
        // Add creation time filter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let calendar = Calendar.current
        var date = Date()
        
        switch timeSpan {
        case "day":
            date = calendar.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        case "month":
            date = calendar.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        case "year":
            date = calendar.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        default:
            date = calendar.date(byAdding: .weekOfYear, value: -1, to: Date()) ?? Date()
        }
        
        let dateString = dateFormatter.string(from: date)
        query += " created:>\(dateString)"
        
        // Add language filter
        if let language = language, !language.isEmpty {
            query += " language:\(language)"
        }
        
        // URL encode the query string
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        
        // Build complete URL
        let endpoint = "https://api.github.com/search/repositories?q=\(encodedQuery)&sort=stars&order=desc"
        
        networkService.request(endpoint: endpoint, method: .get, parameters: nil, headers: nil, useCache: useCache) { (result: Result<SearchRepositoriesResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.items))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getRepositoriesForUser(username: String, page: Int = 1, perPage: Int = 30, useCache: Bool = true, completion: @escaping (Result<[Repository], Error>) -> Void) {
        let endpoint = "https://api.github.com/users/\(username)/repos?page=\(page)&per_page=\(perPage)&sort=updated"
        
        networkService.request(endpoint: endpoint, method: .get, parameters: nil, headers: nil, useCache: useCache) { (result: Result<[Repository], Error>) in
            completion(result)
        }
    }
    
    func getRepositoryDetails(owner: String, name: String, useCache: Bool = true, completion: @escaping (Result<Repository, Error>) -> Void) {
        let endpoint = "https://api.github.com/repos/\(owner)/\(name)"
        
        networkService.request(endpoint: endpoint, method: .get, parameters: nil, headers: nil, useCache: useCache) { (result: Result<Repository, Error>) in
            completion(result)
        }
    }
    
    func searchRepositories(query: String, page: Int = 1, perPage: Int = 30, useCache: Bool = true, completion: @escaping (Result<[Repository], Error>) -> Void) {
        guard !query.isEmpty else {
            completion(.success([]))
            return
        }
        
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let endpoint = "https://api.github.com/search/repositories?q=\(encodedQuery)&page=\(page)&per_page=\(perPage)"
        
        networkService.request(endpoint: endpoint, method: .get, parameters: nil, headers: nil, useCache: useCache) { (result: Result<SearchRepositoriesResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.items))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchRepositoryReadme(owner: String, name: String, completion: @escaping (Result<String, Error>) -> Void) {
        let endpoint = "https://api.github.com/repos/\(owner)/\(name)/readme"
        
        networkService.request(endpoint: endpoint, method: .get, parameters: nil, headers: nil, useCache: true) { (result: Result<ReadmeResponse, Error>) in
            switch result {
            case .success(let response):
                if response.encoding.lowercased() == "base64", let data = Data(base64Encoded: response.content) {
                    if let decoded = String(data: data, encoding: .utf8) {
                        completion(.success(decoded))
                    } else {
                        completion(.failure(NetworkError.decodingError))
                    }
                } else {
                    completion(.success(response.content))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Clear all caches
    func clearCache() {
        networkService.clearCache()
    }
    
    // Clear a specific type of cache
    func clearCache(forType: CacheType) {
        switch forType {
        case .trending:
            // Since trending cache keys might have multiple variations (different languages and time ranges), simplified handling here
            networkService.clearCache(for: "https://api.github.com/search/repositories")
        case .userRepositories(let username):
            networkService.clearCache(for: "https://api.github.com/users/\(username)/repos")
        case .repositoryDetails(let owner, let name):
            networkService.clearCache(for: "https://api.github.com/repos/\(owner)/\(name)")
        case .search(let query):
            let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
            networkService.clearCache(for: "https://api.github.com/search/repositories?q=\(encodedQuery)")
        }
    }
}

// Response structure for search repositories API
struct SearchRepositoriesResponse: Codable {
    let totalCount: Int
    let incompleteResults: Bool
    let items: [Repository]
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case incompleteResults = "incomplete_results"
        case items
    }
}

// Response structure for README API
struct ReadmeResponse: Codable {
    let content: String
    let encoding: String
} 
