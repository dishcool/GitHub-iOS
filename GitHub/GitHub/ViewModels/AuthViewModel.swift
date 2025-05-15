//
//  AuthViewModel.swift
//  GitHub
//
//  Created by Dishcool on 2025/5/15.
//

import Foundation
import SwiftUI
import LocalAuthentication

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User?
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    private var authService: AuthenticationServiceProtocol
    
    init(authService: AuthenticationServiceProtocol = AuthenticationService()) {
        self.authService = authService
        checkAuthenticationStatus()
    }
    
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
    
    func login() {
        isLoading = true
        authService.authenticate { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let user):
                    self?.isAuthenticated = true
                    self?.currentUser = user
                case .failure(let error):
                    self?.error = error
                }
            }
        }
    }
    
    func logout() {
        isLoading = true
        authService.logout { [weak self] result in
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
    
    func authenticateWithBiometric() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Log in to your GitHub account"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, error in
                DispatchQueue.main.async {
                    if success {
                        // Biometric auth succeeded - check keychain for stored credentials
                        self?.authService.authenticateWithBiometric { result in
                            DispatchQueue.main.async {
                                switch result {
                                case .success(let user):
                                    self?.isAuthenticated = true
                                    self?.currentUser = user
                                case .failure(let error):
                                    self?.error = error
                                }
                            }
                        }
                    } else if let error = error {
                        self?.error = error
                    }
                }
            }
        } else {
            self.error = error
        }
    }
} 