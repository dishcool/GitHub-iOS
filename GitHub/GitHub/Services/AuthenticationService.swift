//
//  AuthenticationService.swift
//  GitHub
//
//  Created by Dishcool on 2025/5/15.
//

import Foundation
import OAuthSwift
import KeychainSwift
import SafariServices
import UIKit

enum AuthenticationError: Error {
    case tokenNotFound
    case authorizationFailed
    case networkError
    case biometricNotAvailable
    case unknownError
}

class AuthenticationService: AuthenticationServiceProtocol {
    private let keychain = KeychainSwift()
    private let networkService: NetworkServiceProtocol
    private let clientID = "Ov23lijpUq87uT9pa2yD" // GitHub OAuth client ID
    private let clientSecret = "26a8caee7663039413011fb35dde3daf9feedb29" // GitHub OAuth client secret
    private let redirectURI = "github20250516junjian://callback" // This should match your GitHub OAuth app configuration
    private let tokenKey = "github_oauth_token"
    
    private var oauthSwift: OAuth2Swift?
    
    // Flag indicating if running in simulator environment
    private var isSimulator: Bool {
        // Check if running in simulator environment
        #if targetEnvironment(simulator)
        return true  // Enable auto-login in simulator environment
        #else
        return false
        #endif
    }
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    func authenticate(completion: @escaping (Result<User, Error>) -> Void) {
        oauthSwift = OAuth2Swift(
            consumerKey: clientID,
            consumerSecret: clientSecret,
            authorizeUrl: "https://github.com/login/oauth/authorize",
            accessTokenUrl: "https://github.com/login/oauth/access_token",
            responseType: "code"
        )
        
        guard let oauthSwift = oauthSwift else {
            completion(.failure(AuthenticationError.authorizationFailed))
            return
        }
        
        // Find the top view controller to present the Safari view
        guard let topVC = UIApplication.shared.windows.first?.rootViewController else {
            completion(.failure(AuthenticationError.authorizationFailed))
            return
        }
        
        oauthSwift.authorizeURLHandler = SafariURLHandler(viewController: topVC, oauthSwift: oauthSwift)
        
        let state = generateState(withLength: 20)
        let _ = oauthSwift.authorize(
            withCallbackURL: URL(string: redirectURI)!,
            scope: "user repo",
            state: state) { [weak self] result in
                switch result {
                case .success(let response):
                    // Save token to keychain using the shared KeychainService
                    KeychainService.shared.storeToken(response.credential.oauthToken)
                    
                    // Fetch user data
                    self?.fetchUserProfile(token: response.credential.oauthToken, completion: completion)
                    
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    func authenticateWithBiometric(completion: @escaping (Result<User, Error>) -> Void) {
        // Check if running in simulator environment and has saved token
        if isSimulator, let token = KeychainService.shared.retrieveToken() {
            print("[Auth] Detected simulator environment with saved token, automatically logging in with token")
            fetchUserProfile(token: token, completion: completion)
            return
        }
        
        // Real device environment or simulator without token, use normal biometric authentication flow
        if let token = KeychainService.shared.retrieveToken() {
            fetchUserProfile(token: token, completion: completion)
        } else {
            completion(.failure(AuthenticationError.tokenNotFound))
        }
    }
    
    func logout(completion: @escaping (Result<Void, Error>) -> Void) {
        KeychainService.shared.deleteToken()
        completion(.success(()))
    }
    
    func checkToken(completion: @escaping (Result<User, Error>) -> Void) {
        if let token = KeychainService.shared.retrieveToken() {
            fetchUserProfile(token: token) { result in
                switch result {
                case .success:
                    completion(result)
                case .failure:
                    // If there's an error, delete the token
                    KeychainService.shared.deleteToken()
                    completion(result)
                }
            }
        } else {
            completion(.failure(AuthenticationError.tokenNotFound))
        }
    }
    
    private func fetchUserProfile(token: String, completion: @escaping (Result<User, Error>) -> Void) {
        let headers = ["Authorization": "token \(token)"]
        
        networkService.request(
            endpoint: "https://api.github.com/user",
            method: .get,
            parameters: [:],
            headers: headers,
            useCache: true
        ) { (result: Result<User, Error>) in
            completion(result)
        }
    }
    
    private func generateState(withLength length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map { _ in letters.randomElement()! })
    }
    
} 
