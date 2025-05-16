//
//  NetworkServiceTests.swift
//  GitHubTests
//
//  Created by Dishcool on 2025/5/15.
//

import XCTest
@testable import GitHub

final class NetworkServiceTests: XCTestCase {
    
    var mockNetworkService: MockNetworkService!
    
    override func setUpWithError() throws {
        mockNetworkService = MockNetworkService()
    }
    
    override func tearDownWithError() throws {
        mockNetworkService = nil
    }
    
    func testSuccessfulRequest() {
        // Given
        let expectation = XCTestExpectation(description: "Successful network request")
        let mockUser = User.placeholder
        mockNetworkService.mockResult = MockNetworkService.MockResultType.success(mockUser)
        
        // When
        mockNetworkService.request(endpoint: "https://api.github.com/user", method: .get, parameters: nil, headers: nil, useCache: false) { (result: Result<User, Error>) in
            // Then
            switch result {
            case .success(let user):
                XCTAssertEqual(user.id, mockUser.id)
                XCTAssertEqual(user.login, mockUser.login)
            case .failure(let error):
                XCTFail("Request should not fail: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFailedRequestWithNetworkError() {
        // Given
        let expectation = XCTestExpectation(description: "Failed network request")
        mockNetworkService.mockResult = MockNetworkService.MockResultType.failure(NetworkError.networkError)
        
        // When
        mockNetworkService.request(endpoint: "https://api.github.com/user", method: .get, parameters: nil, headers: nil, useCache: false) { (result: Result<User, Error>) in
            // Then
            switch result {
            case .success:
                XCTFail("Request should fail")
            case .failure(let error):
                XCTAssertNotNil(error)
                if let networkError = error as? NetworkError {
                    XCTAssertEqual(networkError, NetworkError.unknown)
                } else {
                    XCTFail("Unexpected error type: \(error)")
                }
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFailedRequestWithDecodingError() {
        // Given
        let expectation = XCTestExpectation(description: "Failed with decoding error")
        mockNetworkService.mockResult = MockNetworkService.MockResultType.failure(NetworkError.decodingError)
        
        // When
        mockNetworkService.request(endpoint: "https://api.github.com/user", method: .get, parameters: nil, headers: nil, useCache: false) { (result: Result<User, Error>) in
            // Then
            switch result {
            case .success:
                XCTFail("Request should fail with decoding error")
            case .failure(let error):
                if let networkError = error as? NetworkError {
                    XCTAssertEqual(networkError, NetworkError.decodingError)
                } else {
                    XCTFail("Unexpected error type: \(error)")
                }
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testCachingBehavior() {
        // Given
        let expectation1 = XCTestExpectation(description: "First request")
        let expectation2 = XCTestExpectation(description: "Second request (cached)")
        
        let mockUser = User.placeholder
        mockNetworkService.mockResult = MockNetworkService.MockResultType.success(mockUser)
        mockNetworkService.shouldCountRequests = true
        
        // When - First request
        mockNetworkService.request(endpoint: "https://api.github.com/user", method: .get, parameters: nil, headers: nil, useCache: true) { (result: Result<User, Error>) in
            // Then
            switch result {
            case .success(let user):
                XCTAssertEqual(user.id, mockUser.id)
            case .failure(let error):
                XCTFail("Request should not fail: \(error)")
            }
            expectation1.fulfill()
            
            // When - Second request (should use cache)
            self.mockNetworkService.request(endpoint: "https://api.github.com/user", method: .get, parameters: nil, headers: nil, useCache: true) { (result: Result<User, Error>) in
                // Then
                XCTAssertEqual(self.mockNetworkService.requestCount, 1, "Second request should use cache")
                expectation2.fulfill()
            }
        }
        
        wait(for: [expectation1, expectation2], timeout: 1.0)
    }
    
    func testClearCache() {
        // Given
        mockNetworkService.mockResult = MockNetworkService.MockResultType.success(User.placeholder)
        
        // When
        mockNetworkService.clearCache()
        
        // Then
        XCTAssertTrue(mockNetworkService.cacheClearedAll)
    }
    
    func testClearCacheForEndpoint() {
        // Given
        let endpoint = "https://api.github.com/user"
        mockNetworkService.mockResult = MockNetworkService.MockResultType.success(User.placeholder)
        
        // When
        mockNetworkService.clearCache(for: endpoint)
        
        // Then
        XCTAssertTrue(mockNetworkService.cacheClearedForEndpoint)
        XCTAssertEqual(mockNetworkService.clearedEndpoint, endpoint)
    }
}

// MARK: - Network Error Extension
extension NetworkError {
    static let networkError = NetworkError.unknown
}

// MARK: - Mock Network Service
class MockNetworkService: NetworkServiceProtocol {
    // 使用一个枚举来更好地处理不同类型的结果
    enum MockResultType {
        case success(Any)
        case failure(Error)
    }
    
    var mockResult: MockResultType?
    var requestCount = 0
    var shouldCountRequests = false
    var cacheClearedAll = false
    var cacheClearedForEndpoint = false
    var clearedEndpoint: String = ""
    private var cachedEndpoints = Set<String>() // 跟踪已缓存的端点
    
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        parameters: [String: Any]?,
        headers: [String: String]?,
        useCache: Bool,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        // 如果启用缓存并且端点已经被缓存，则不增加请求计数
        let cacheKey = "\(endpoint)-\(method.rawValue)"
        let isCached = useCache && cachedEndpoints.contains(cacheKey)
        
        if shouldCountRequests && !isCached {
            requestCount += 1
            // 如果启用了缓存，将端点添加到缓存集合中
            if useCache {
                cachedEndpoints.insert(cacheKey)
            }
        }
        
        if let mockResult = mockResult {
            switch mockResult {
            case .success(let value):
                if let typedValue = value as? T {
                    completion(.success(typedValue))
                } else {
                    completion(.failure(NetworkError.decodingError))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        } else {
            completion(.failure(NetworkError.unknown))
        }
    }
    
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        request(endpoint: endpoint, method: method, parameters: nil, headers: nil, useCache: false, completion: completion)
    }
    
    func clearCache() {
        cacheClearedAll = true
        cachedEndpoints.removeAll()
    }
    
    func clearCache(for endpoint: String) {
        cacheClearedForEndpoint = true
        clearedEndpoint = endpoint
        cachedEndpoints.remove("\(endpoint)-GET")
        cachedEndpoints.remove("\(endpoint)-POST")
        cachedEndpoints.remove("\(endpoint)-PUT")
        cachedEndpoints.remove("\(endpoint)-DELETE")
    }
} 