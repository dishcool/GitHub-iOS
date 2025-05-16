//
//  AuthenticationManager.swift
//  GitHub
//
//  Created by Dishcool on 2025/5/16.
//

import Foundation
import Combine

/// Central manager for tracking authentication state across the app
class AuthenticationManager {
    static let shared = AuthenticationManager()
    
    /// Published property that changes when auth state changes
    @Published private(set) var isAuthenticated: Bool = false
    
    /// Authentication service
    private let authService: AuthenticationServiceProtocol
    
    /// Cancellables for Combine subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    /// Private initializer for singleton
    private init(authService: AuthenticationServiceProtocol = AuthenticationService()) {
        self.authService = authService
        
        // Set initial state based on token presence
        checkAuthState()
    }
    
    /// Check current authentication state
    func checkAuthState() {
        isAuthenticated = KeychainService.shared.hasToken()
    }
    
    /// Attempt to authenticate silently using stored token
    func authenticateSilently(completion: @escaping (Bool) -> Void) {
        if !KeychainService.shared.hasToken() {
            isAuthenticated = false
            completion(false)
            return
        }
        
        authService.checkToken { [weak self] result in
            switch result {
            case .success(_):
                self?.isAuthenticated = true
                completion(true)
            case .failure(_):
                self?.isAuthenticated = false
                completion(false)
            }
        }
    }
    
    /// Start OAuth authentication flow
    func authenticate(completion: @escaping (Result<Void, Error>) -> Void) {
        authService.authenticate { [weak self] result in
            switch result {
            case .success(_):
                self?.isAuthenticated = true
                completion(.success(()))
            case .failure(let error):
                self?.isAuthenticated = false
                completion(.failure(error))
            }
        }
    }
    
    /// Log user out
    func logout(completion: @escaping (Result<Void, Error>) -> Void) {
        authService.logout { [weak self] result in
            switch result {
            case .success(_):
                self?.isAuthenticated = false
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
} 