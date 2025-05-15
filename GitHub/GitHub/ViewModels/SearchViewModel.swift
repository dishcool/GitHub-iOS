//
//  SearchViewModel.swift
//  GitHub
//
//  Created by Dishcool on 2025/5/15.
//

import Foundation
import Combine

enum SearchSegment: Int, CaseIterable {
    case repositories
    case users
    case organizations
    
    var title: String {
        switch self {
        case .repositories:
            return "Repositories"
        case .users:
            return "Users"
        case .organizations:
            return "Organizations"
        }
    }
}

class SearchViewModel: ObservableObject {
    @Published var searchQuery: String = ""
    @Published var selectedSegment: SearchSegment = .repositories
    @Published var repositories: [Repository] = []
    @Published var users: [User] = []
    @Published var organizations: [User] = [] // Organizations use the same API model as users
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    private var searchCancellable: AnyCancellable?
    private let repositoryService: RepositoryServiceProtocol
    private let userService: UserServiceProtocol
    
    init(repositoryService: RepositoryServiceProtocol = RepositoryService(),
         userService: UserServiceProtocol = UserService()) {
        self.repositoryService = repositoryService
        self.userService = userService
        
        setupSearchPublisher()
    }
    
    private func setupSearchPublisher() {
        searchCancellable = $searchQuery
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .filter { !$0.isEmpty }
            .sink { [weak self] query in
                self?.performSearch(query: query)
            }
    }
    
    func performSearch(query: String) {
        guard !query.isEmpty else { return }
        
        isLoading = true
        error = nil
        
        switch selectedSegment {
        case .repositories:
            searchRepositories(query: query)
        case .users:
            searchUsers(query: query, isOrganization: false)
        case .organizations:
            searchUsers(query: "\(query) type:org", isOrganization: true)
        }
    }
    
    private func searchRepositories(query: String) {
        repositoryService.searchRepositories(query: query, page: 1, perPage: 30, useCache: true) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let repositories):
                    self?.repositories = repositories
                case .failure(let error):
                    self?.error = error
                }
            }
        }
    }
    
    private func searchUsers(query: String, isOrganization: Bool) {
        userService.searchUsers(query: query, page: 1, perPage: 30) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let users):
                    if isOrganization {
                        self?.organizations = users
                    } else {
                        self?.users = users
                    }
                case .failure(let error):
                    self?.error = error
                }
            }
        }
    }
} 
