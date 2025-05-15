//
//  RepositoryService.swift
//  GitHub
//
//  Created by Dishcool on 2025/5/15.
//

import Foundation

// 删除typealias并直接使用NetworkServiceProtocol

class RepositoryService: RepositoryServiceProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    func getTrendingRepositories(language: String? = nil, timeSpan: String? = nil, useCache: Bool = true, completion: @escaping (Result<[Repository], Error>) -> Void) {
        // 构建查询字符串
        var query = "stars:>100"
        
        // 添加创建时间筛选
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
        
        // 添加语言筛选
        if let language = language, !language.isEmpty {
            query += " language:\(language)"
        }
        
        // URL编码查询字符串
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        
        // 构建完整URL
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
    
    // 清除所有缓存
    func clearCache() {
        networkService.clearCache()
    }
    
    // 清除特定类型的缓存
    func clearCache(forType: CacheType) {
        switch forType {
        case .trending:
            // 由于trending缓存键可能有多种（不同语言和时间范围），此处简化处理
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