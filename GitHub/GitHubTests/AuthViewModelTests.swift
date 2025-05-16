//
//  AuthViewModelTests.swift
//  GitHubTests
//
//  Created by Dishcool on 2025/5/15.
//

import XCTest
@testable import GitHub

final class AuthViewModelTests: XCTestCase {
    
    var sut: AuthViewModel!
    var mockAuthService: MockAuthenticationService!
    
    override func setUpWithError() throws {
        mockAuthService = MockAuthenticationService()
        sut = AuthViewModel(authService: mockAuthService)
    }
    
    override func tearDownWithError() throws {
        sut = nil
        mockAuthService = nil
    }
    
    func testLoginSuccess() {
        // Given
        let expectation = XCTestExpectation(description: "Login success")
        let mockUser = User.placeholder
        mockAuthService.authenticateResult = .success(mockUser)
        
        // When
        sut.login()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
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
        mockAuthService.authenticateResult = .failure(AuthenticationError.networkError)
        
        // When
        sut.login()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertFalse(self.sut.isAuthenticated)
            XCTAssertNil(self.sut.currentUser)
            XCTAssertFalse(self.sut.isLoading)
            XCTAssertNotNil(self.sut.error)
            if let error = self.sut.error as? AuthenticationError, case .networkError = error {
                // Error type is correct
            } else {
                XCTFail("Unexpected error type")
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
        
        // When
        sut.checkAuthenticationStatus()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
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
        
        // When
        sut.checkAuthenticationStatus()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
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
        mockAuthService.logoutResult = .success(())
        
        // Set up a logged-in state
        sut.isAuthenticated = true
        sut.currentUser = User.placeholder
        
        // When
        sut.logout()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertFalse(self.sut.isAuthenticated)
            XCTAssertNil(self.sut.currentUser)
            XCTAssertFalse(self.sut.isLoading)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testHasToken() {
        // Given
        mockAuthService.hasTokenResult = true
        
        // When
        let result = sut.hasToken()
        
        // Then
        XCTAssertTrue(result)
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