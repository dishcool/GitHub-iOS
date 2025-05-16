//
//  KeychainServiceProtocol.swift
//  GitHub
//
//  Created by Dishcool on 2025/5/16.
//

import Foundation

/// Protocol defining the keychain service operations for token management
protocol KeychainServiceProtocol {
    /// Store a token in the keychain
    /// - Parameter token: The OAuth token to store
    /// - Returns: True if storage was successful
    @discardableResult
    func storeToken(_ token: String) -> Bool
    
    /// Retrieve the stored token from keychain
    /// - Returns: The stored token, or nil if not found
    func retrieveToken() -> String?
    
    /// Delete the stored token
    /// - Returns: True if deletion was successful
    @discardableResult
    func deleteToken() -> Bool
    
    /// Check if a token exists in the keychain
    /// - Returns: True if a token exists
    func hasToken() -> Bool
} 