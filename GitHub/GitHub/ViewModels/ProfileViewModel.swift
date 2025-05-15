//
//  ProfileViewModel.swift
//  GitHub
//
//  Created by Dishcool on 2025/5/15.
//

import Foundation
import Combine

class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var repositories: [Repository] = []
    @Published var isLoadingUser: Bool = false
    @Published var isLoadingRepos: Bool = false
    @Published var error: Error?
    
    private let userService: UserServiceProtocol
    private let repositoryService: RepositoryServiceProtocol
    
    init(user: User? = nil,
         userService: UserServiceProtocol = UserService(),
         repositoryService: RepositoryServiceProtocol = RepositoryService()) {
        self.user = user
        self.userService = userService
        self.repositoryService = repositoryService
    }
    
    func loadUserProfile(username: String? = nil) {
        guard let username = username ?? user?.login else { return }
        
        isLoadingUser = true
        error = nil
        
        userService.getUserProfile(username: username) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoadingUser = false
                switch result {
                case .success(let user):
                    self?.user = user
                    self?.loadUserRepositories(username: user.login)
                case .failure(let error):
                    self?.error = error
                }
            }
        }
    }
    
    func loadUserRepositories(username: String? = nil) {
        guard let username = username ?? user?.login else { return }
        
        isLoadingRepos = true
        error = nil
        
        repositoryService.getRepositoriesForUser(username: username, page: 1, perPage: 30, useCache: true) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoadingRepos = false
                switch result {
                case .success(let repositories):
                    self?.repositories = repositories
                case .failure(let error):
                    self?.error = error
                }
            }
        }
    }
    
    func refresh() {
        if let login = user?.login {
            loadUserProfile(username: login)
        }
    }
} 
