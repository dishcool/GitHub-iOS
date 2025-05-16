//
//  IssuesService.swift
//  GitHub
//
//  Created by Dishcool on 2025/5/21.
//

import Foundation
import Combine

protocol IssuesServiceProtocol {
    func getIssues(owner: String, repo: String) async throws -> [Issue]
    func getIssueDetail(owner: String, repo: String, issueNumber: Int) async throws -> Issue
}

class IssuesService: IssuesServiceProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    func getIssues(owner: String, repo: String) async throws -> [Issue] {
        return try await withCheckedThrowingContinuation { continuation in
            let endpoint = "https://api.github.com/repos/\(owner)/\(repo)/issues?state=all"
            networkService.request(endpoint: endpoint, method: .get) { (result: Result<[Issue], Error>) in
                switch result {
                case .success(let issues):
                    continuation.resume(returning: issues)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func getIssueDetail(owner: String, repo: String, issueNumber: Int) async throws -> Issue {
        return try await withCheckedThrowingContinuation { continuation in
            let endpoint = "https://api.github.com/repos/\(owner)/\(repo)/issues/\(issueNumber)"
            networkService.request(endpoint: endpoint, method: .get) { (result: Result<Issue, Error>) in
                switch result {
                case .success(let issue):
                    continuation.resume(returning: issue)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
} 