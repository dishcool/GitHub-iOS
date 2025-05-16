//
//  AuthViewModel.swift
//  GitHub
//
//  Created by Dishcool on 2025/5/15.
//

import Foundation
import SwiftUI
import LocalAuthentication
import KeychainSwift

class AuthViewModel: ObservableObject {
    /// Indicates whether a user is currently authenticated
    @Published var isAuthenticated: Bool = false
    
    /// Current authenticated user info, or nil if not authenticated
    @Published var currentUser: User?
    
    /// Indicates whether an authentication operation is in progress
    @Published var isLoading: Bool = false
    
    /// Error that occurred during the last authentication operation, if any
    @Published var error: Error?
    
    private var authService: AuthenticationServiceProtocol
    private let authManager: AuthenticationManager
    private var loginStartTime: Date?
    
    // Use the utility class instead of duplicating code
    private var isRunningOnSimulator: Bool {
        return EnvironmentUtility.isRunningOnSimulator
    }
    
    /// Initialize the view model
    /// - Parameters:
    ///   - authService: Service for handling authentication operations
    ///   - authManager: Manager for handling authentication state
    init(authService: AuthenticationServiceProtocol = AuthenticationService(), 
         authManager: AuthenticationManager = AuthenticationManager.shared) {
        self.authService = authService
        self.authManager = authManager
        
        // Set initial authentication state from AuthManager
        self.isAuthenticated = authManager.isAuthenticated
        
        // If in simulator environment and have a saved token, automatically check login status at startup
        if isRunningOnSimulator && KeychainService.shared.hasToken() {
            print("[Auth] Application launch, detected simulator environment with saved token, automatically checking login status")
            checkAuthenticationStatus()
        }
    }
    
    /// Check if a token exists in the keychain
    /// - Returns: True if a token exists
    func hasToken() -> Bool {
        return KeychainService.shared.hasToken()
    }
    
    /// Reset the loading state to false
    /// This is useful for recovering from interrupted authentication flows
    func resetLoadingState() {
        // Directly reset loading state
        DispatchQueue.main.async {
            self.isLoading = false
            self.loginStartTime = nil
        }
    }
    
    /// Check the current authentication status by validating the stored token
    func checkAuthenticationStatus() {
        isLoading = true
        authService.checkToken { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let user):
                    self?.isAuthenticated = true
                    self?.currentUser = user
                case .failure(let error):
                    self?.isAuthenticated = false
                    self?.currentUser = nil
                    self?.error = error
                }
            }
        }
    }
    
    /// Initiate the login process
    func login() {
        isLoading = true
        loginStartTime = Date()
        
        authManager.authenticate { [weak self] result in
            guard let self = self else { return }
            
            // Keep the loading state active until we've fetched the user profile
            // to avoid UI jumping between states
            
            switch result {
            case .success:
                // Set authenticated first but keep loading
                self.isAuthenticated = true
                // For unit tests, if currentUser is already set, don't fetch it again
                if self.currentUser != nil {
                    // Just complete the loading state immediately
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.loginStartTime = nil
                    }
                } else {
                    // Fetch user profile before completing the loading state
                    self.fetchUserProfile { 
                        DispatchQueue.main.async {
                            self.isLoading = false
                            self.loginStartTime = nil
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.loginStartTime = nil
                    self.error = error
                }
            }
        }
    }
    
    /// Log out the current user
    func logout() {
        isLoading = true
        authManager.logout { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success:
                    self?.isAuthenticated = false
                    self?.currentUser = nil
                case .failure(let error):
                    self?.error = error
                }
            }
        }
    }
    
    // Fetch current user profile with completion handler
    private func fetchUserProfile(completion: @escaping () -> Void = {}) {
        guard let token = KeychainService.shared.retrieveToken() else {
            completion()
            return
        }
        
        let headers = ["Authorization": "token \(token)"]
        let networkService = NetworkService()
        
        networkService.request(
            endpoint: "https://api.github.com/user",
            method: .get,
            parameters: nil,
            headers: headers,
            useCache: true
        ) { [weak self] (result: Result<User, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    // Store currentUser first, then notify
                    self?.currentUser = user
                    self?.objectWillChange.send()
                case .failure(let error):
                    self?.error = error
                    // If we can't get user data, invalidate authentication
                    if let networkError = error as? NetworkError, 
                       case .unauthorized = networkError {
                        self?.isAuthenticated = false
                        KeychainService.shared.deleteToken()
                    }
                }
                completion()
            }
        }
    }
    
    func authenticateWithBiometric() {
        print("[Auth] Attempting biometric authentication")
        isLoading = true
        
        // If in simulator environment with a token, try to login directly using the token without biometric auth
        if isRunningOnSimulator && hasToken() {
            print("[Auth] Detected simulator environment with saved token, skipping biometric authentication and trying to login directly")
            
            authService.authenticateWithBiometric { [weak self] result in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    switch result {
                    case .success(let user):
                        self?.isAuthenticated = true
                        self?.currentUser = user
                        print("[Auth] Simulator auth successful, user: \(user.login)")
                    case .failure(let error):
                        self?.error = error
                        print("[Auth] Simulator auth failed: \(error.localizedDescription)")
                    }
                }
            }
            return
        }
        
        // Real device environment or simulator without token, use normal biometric authentication flow
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Log in to your GitHub account"
            print("[Auth] Starting biometric authentication on physical device")
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, error in
                DispatchQueue.main.async {
                    if success {
                        print("[Auth] Biometric authentication successful, proceeding to token check")
                        // Biometric auth succeeded - check keychain for stored credentials
                        self?.authService.authenticateWithBiometric { result in
                            DispatchQueue.main.async {
                                self?.isLoading = false
                                switch result {
                                case .success(let user):
                                    print("[Auth] Token authentication successful, user: \(user.login)")
                                    self?.isAuthenticated = true
                                    self?.currentUser = user
                                case .failure(let error):
                                    print("[Auth] Token authentication failed: \(error.localizedDescription)")
                                    self?.error = error
                                }
                            }
                        }
                    } else if let error = error {
                        print("[Auth] Biometric authentication failed: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            self?.isLoading = false
                            self?.error = error
                        }
                    } else {
                        print("[Auth] Biometric authentication cancelled by user")
                        DispatchQueue.main.async {
                            self?.isLoading = false
                        }
                    }
                }
            }
        } else {
            print("[Auth] Biometric authentication not available: \(error?.localizedDescription ?? "Unknown error")")
            DispatchQueue.main.async {
                self.isLoading = false
                self.error = error ?? NSError(domain: "AuthViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "Biometric authentication not available"])
            }
        }
    }
    
    // Cancel login process
    func cancelLogin() {
        DispatchQueue.main.async {
            self.isLoading = false
            self.loginStartTime = nil
        }
    }
} 
