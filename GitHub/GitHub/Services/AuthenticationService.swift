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

/// Errors specific to the authentication process
enum AuthenticationError: Error {
    /// No authentication token found in storage
    case tokenNotFound
    /// Failed to complete the OAuth authorization flow
    case authorizationFailed
    /// Network error during authentication
    case networkError
    /// Biometric authentication is not available on this device
    case biometricNotAvailable
    /// Unknown error during authentication
    case unknownError
}

/// Service handling authentication operations with GitHub
class AuthenticationService: AuthenticationServiceProtocol {
    private let keychain = KeychainSwift()
    private let networkService: NetworkServiceProtocol
    
    private var oauthSwift: OAuth2Swift?
    
    // Use the utility class instead of duplicating code
    private var isSimulator: Bool {
        return EnvironmentUtility.isRunningOnSimulator
    }
    
    /// Initialize the authentication service
    /// - Parameter networkService: Service for making network requests
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    /// Initiate the OAuth authentication flow with GitHub
    /// - Parameter completion: Callback with the result containing the authenticated user or an error
    func authenticate(completion: @escaping (Result<User, Error>) -> Void) {
        oauthSwift = OAuth2Swift(
            consumerKey: AppConstants.GitHub.clientID,
            consumerSecret: AppConstants.GitHub.clientSecret,
            authorizeUrl: AppConstants.GitHub.authorizeUrl,
            accessTokenUrl: AppConstants.GitHub.accessTokenUrl,
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
            withCallbackURL: URL(string: AppConstants.GitHub.redirectURI)!,
            scope: AppConstants.GitHub.scopes,
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
    
    /// Authenticate using biometrics (or stored token on simulator)
    /// - Parameter completion: Callback with the result containing the authenticated user or an error
    func authenticateWithBiometric(completion: @escaping (Result<User, Error>) -> Void) {
        // Check if running in simulator environment and has saved token
        if isSimulator, let token = KeychainService.shared.retrieveToken() {
            print(AppStrings.Auth.simulatorAutoLogin)
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
    
    /// Log out the current user by removing the stored token
    /// - Parameter completion: Callback with the result of the logout operation
    func logout(completion: @escaping (Result<Void, Error>) -> Void) {
        KeychainService.shared.deleteToken()
        completion(.success(()))
    }
    
    /// Check if the stored token is valid
    /// - Parameter completion: Callback with the result containing the authenticated user or an error
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
    
    /// Fetch the user profile using the provided token
    /// - Parameters:
    ///   - token: GitHub OAuth token
    ///   - completion: Callback with the result containing the user profile or an error
    private func fetchUserProfile(token: String, completion: @escaping (Result<User, Error>) -> Void) {
        let headers = [
            AppConstants.Network.Headers.authorization: String(format: AppConstants.Network.HeaderValues.tokenFormat, token)
        ]
        
        networkService.request(
            endpoint: AppConstants.GitHub.apiBaseUrl + AppConstants.GitHub.Endpoints.user,
            method: .get,
            parameters: [:],
            headers: headers,
            useCache: true
        ) { (result: Result<User, Error>) in
            completion(result)
        }
    }
    
    /// Generate a random state string for OAuth security
    /// - Parameter length: Length of the random string to generate
    /// - Returns: Random string of the specified length
    private func generateState(withLength length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map { _ in letters.randomElement()! })
    }
} 
