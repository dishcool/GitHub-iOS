//
//  UserService.swift
//  GitHub
//
//  Created by Dishcool on 2025/5/15.
//

import Foundation

class UserService: UserServiceProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    func getUserProfile(username: String, completion: @escaping (Result<User, Error>) -> Void) {
        let endpoint = "https://api.github.com/users/\(username)"
        
        networkService.request(endpoint: endpoint, method: .get) { (result: Result<User, Error>) in
            completion(result)
        }
    }
    
    func searchUsers(query: String, page: Int = 1, perPage: Int = 30, completion: @escaping (Result<[User], Error>) -> Void) {
        guard !query.isEmpty else {
            completion(.success([]))
            return
        }
        
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let endpoint = "https://api.github.com/search/users?q=\(encodedQuery)&page=\(page)&per_page=\(perPage)"
        
        networkService.request(endpoint: endpoint, method: .get) { (result: Result<SearchUsersResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.items))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// Response structure for search users API
struct SearchUsersResponse: Codable {
    let totalCount: Int
    let incompleteResults: Bool
    let items: [User]
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case incompleteResults = "incomplete_results"
        case items
    }
} 