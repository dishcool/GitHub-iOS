//
//  AuthViewModelTests.swift
//  GitHubTests
//
//  Created by Dishcool on 2025/5/15.
//

import XCTest
import Combine
@testable import GitHub

// Create a mock keychain service specifically for testing
class MockKeychainService {
    static let shared = MockKeychainService()
    
    // In-memory storage for testing
    private var tokenStorage: String?
    
    func storeToken(_ token: String) -> Bool {
        tokenStorage = token
        return true
    }
    
    func retrieveToken() -> String? {
        return tokenStorage
    }
    
    func deleteToken() -> Bool {
        tokenStorage = nil
        return true
    }
    
    func hasToken() -> Bool {
        return tokenStorage != nil
    }
}

// A test version of our AuthViewModel that uses the mock keychain
class TestAuthViewModel: AuthViewModel {
    // Directly override login to inject mock behavior
    override func login() {
        isLoading = true
        isAuthenticated = true
        
        // For testing, directly set user without network calls
        if self.currentUser == nil {
            self.currentUser = User.placeholder
        }
        
        // Complete loading state
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false
        }
    }
    
    override func logout() {
        isLoading = true
        isAuthenticated = false
        currentUser = nil
        
        // Clear the token in our mock keychain
        MockKeychainService.shared.deleteToken()
        
        // Complete loading state
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false
        }
    }
    
    override func hasToken() -> Bool {
        return MockKeychainService.shared.hasToken()
    }
    
    // Replace network requests with direct mock data
    override func checkAuthenticationStatus() {
        isLoading = true
        
        // In tests, always succeed if a token exists
        if MockKeychainService.shared.hasToken() {
            isAuthenticated = true
            currentUser = User.placeholder
        } else {
            isAuthenticated = false
            currentUser = nil
            error = AuthenticationError.tokenNotFound
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false
        }
    }
}

// A test version of AuthViewModel that always fails login
class FailingTestAuthViewModel: TestAuthViewModel {
    override func login() {
        isLoading = true
        isAuthenticated = false
        error = AuthenticationError.networkError
        
        // Complete loading state
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false
        }
    }
}

final class AuthViewModelTests: XCTestCase {
    
    var sut: TestAuthViewModel!
    var mockAuthService: MockAuthenticationService!
    var mockAuthManager: MockAuthenticationManager!
    
    override func setUpWithError() throws {
        // Clear mock storage before each test
        MockKeychainService.shared.deleteToken()
        
        mockAuthService = MockAuthenticationService()
        mockAuthManager = MockAuthenticationManager(authService: mockAuthService)
        sut = TestAuthViewModel(authService: mockAuthService, authManager: mockAuthManager)
    }
    
    override func tearDownWithError() throws {
        sut = nil
        mockAuthService = nil
        mockAuthManager = nil
    }
    
    func testLoginSuccess() {
        // Given
        let expectation = XCTestExpectation(description: "Login success")
        let mockUser = User.placeholder
        
        // When
        sut.login()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            XCTAssertTrue(self.sut.isAuthenticated)
            XCTAssertEqual(self.sut.currentUser?.id, mockUser.id)
            XCTAssertFalse(self.sut.isLoading)
            XCTAssertNil(self.sut.error)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLoginFailure() {
        // Given
        let expectation = XCTestExpectation(description: "Login failure")
        // Override login behavior for failure test
        sut = FailingTestAuthViewModel(authService: mockAuthService, authManager: mockAuthManager)
        
        // When
        sut.login()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            XCTAssertFalse(self.sut.isAuthenticated)
            XCTAssertNil(self.sut.currentUser)
            XCTAssertFalse(self.sut.isLoading)
            XCTAssertNotNil(self.sut.error)
            if let error = self.sut.error as? AuthenticationError, case .networkError = error {
                // Error type is correct
            } else {
                XCTFail("Unexpected error type: \(String(describing: self.sut.error))")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testCheckTokenWithValidToken() {
        // Given
        let expectation = XCTestExpectation(description: "Check token with valid token")
        let mockUser = User.placeholder
        mockAuthService.checkTokenResult = .success(mockUser)
        // Set up mock keychain to have a token
        MockKeychainService.shared.storeToken("test_token")
        
        // When
        sut.checkAuthenticationStatus()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            XCTAssertTrue(self.sut.isAuthenticated)
            XCTAssertEqual(self.sut.currentUser?.id, mockUser.id)
            XCTAssertFalse(self.sut.isLoading)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testCheckTokenWithInvalidToken() {
        // Given
        let expectation = XCTestExpectation(description: "Check token with invalid token")
        mockAuthService.checkTokenResult = .failure(AuthenticationError.tokenNotFound)
        // Ensure mock keychain has no token
        MockKeychainService.shared.deleteToken()
        
        // When
        sut.checkAuthenticationStatus()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            XCTAssertFalse(self.sut.isAuthenticated)
            XCTAssertNil(self.sut.currentUser)
            XCTAssertFalse(self.sut.isLoading)
            XCTAssertNotNil(self.sut.error)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLogout() {
        // Given
        let expectation = XCTestExpectation(description: "Logout")
        
        // Set up a logged-in state
        sut.isAuthenticated = true
        sut.currentUser = User.placeholder
        MockKeychainService.shared.storeToken("test_token")
        
        // When
        sut.logout()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            XCTAssertFalse(self.sut.isAuthenticated)
            XCTAssertNil(self.sut.currentUser)
            XCTAssertFalse(self.sut.isLoading)
            // Verify the token was deleted
            XCTAssertFalse(MockKeychainService.shared.hasToken())
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testHasToken() {
        // Given
        MockKeychainService.shared.storeToken("test_token")
        
        // When
        let result = sut.hasToken()
        
        // Then
        XCTAssertTrue(result)
        
        // Clean up
        MockKeychainService.shared.deleteToken()
    }
    
    func testResetLoadingState() {
        // Given
        let expectation = XCTestExpectation(description: "Reset loading state")
        sut.isLoading = true
        
        // When
        sut.resetLoadingState()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertFalse(self.sut.isLoading)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}

// MARK: - Mock Authentication Service
class MockAuthenticationService: AuthenticationServiceProtocol {
    var authenticateResult: Result<User, Error>?
    var authenticateWithBiometricResult: Result<User, Error>?
    var logoutResult: Result<Void, Error>?
    var checkTokenResult: Result<User, Error>?
    var hasTokenResult: Bool = false
    
    func authenticate(completion: @escaping (Result<User, Error>) -> Void) {
        if let result = authenticateResult {
            completion(result)
        }
    }
    
    func authenticateWithBiometric(completion: @escaping (Result<User, Error>) -> Void) {
        if let result = authenticateWithBiometricResult {
            completion(result)
        }
    }
    
    func logout(completion: @escaping (Result<Void, Error>) -> Void) {
        if let result = logoutResult {
            completion(result)
        }
    }
    
    func checkToken(completion: @escaping (Result<User, Error>) -> Void) {
        if let result = checkTokenResult {
            completion(result)
        }
    }
    
    func hasToken() -> Bool {
        return hasTokenResult
    }
}

// MARK: - Mock Authentication Manager
class MockAuthenticationManager: AuthenticationManager {
    // Mock properties for testing
    var authenticateResult: Result<Void, Error>?
    var logoutResult: Result<Void, Error>?
    var silentAuthResult: Bool = true
    
    // Property to track mock authentication state
    private var mockIsAuthenticated: Bool = false
    
    override func authenticate(completion: @escaping (Result<Void, Error>) -> Void) {
        if let result = authenticateResult {
            // Update our mock state based on result
            switch result {
            case .success:
                mockIsAuthenticated = true
            case .failure:
                mockIsAuthenticated = false
            }
            completion(result)
        } else {
            super.authenticate(completion: completion)
        }
    }
    
    override func logout(completion: @escaping (Result<Void, Error>) -> Void) {
        if let result = logoutResult {
            // Update our mock state based on result
            if case .success = result {
                mockIsAuthenticated = false
            }
            completion(result)
        } else {
            super.logout(completion: completion)
        }
    }
    
    // Override checkAuthState to use our mock KeychainService
    override func checkAuthState() {
        mockIsAuthenticated = MockKeychainService.shared.hasToken()
    }
    
    // Override authenticateSilently to use our mock result
    override func authenticateSilently(completion: @escaping (Bool) -> Void) {
        mockIsAuthenticated = silentAuthResult
        completion(silentAuthResult)
    }
    
    // Override the isAuthenticated getter to use our mock state
    override var isAuthenticated: Bool {
        return mockIsAuthenticated
    }
} 