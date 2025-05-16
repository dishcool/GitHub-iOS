//
//  KeychainService.swift
//  GitHub
//
//  Created by Dishcool on 2025/5/16.
//

import Foundation
import KeychainSwift

/// Service for securely storing and retrieving auth tokens
class KeychainService: KeychainServiceProtocol {
    /// Shared instance of the keychain service
    static let shared = KeychainService()
    
    private let keychain = KeychainSwift()
    private let tokenKey = "github_oauth_token"
    
    private init() {
        // Private initializer to enforce singleton pattern
    }
    
    /// Store a token in the keychain
    /// - Parameter token: The OAuth token to store
    /// - Returns: True if storage was successful
    @discardableResult
    func storeToken(_ token: String) -> Bool {
        return keychain.set(token, forKey: tokenKey)
    }
    
    /// Retrieve the stored token from keychain
    /// - Returns: The stored token, or nil if not found
    func retrieveToken() -> String? {
        return keychain.get(tokenKey)
    }
    
    /// Delete the stored token
    /// - Returns: True if deletion was successful
    @discardableResult
    func deleteToken() -> Bool {
        return keychain.delete(tokenKey)
    }
    
    /// Check if a token exists in the keychain
    /// - Returns: True if a token exists
    func hasToken() -> Bool {
        return retrieveToken() != nil
    }
} 