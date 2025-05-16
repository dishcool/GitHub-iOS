//
//  RepositoryServiceTests.swift
//  GitHubTests
//
//  Created by Dishcool on 2025/5/15.
//

import XCTest
@testable import GitHub

final class RepositoryServiceTests: XCTestCase {
    
    var sut: RepositoryService!
    var mockNetworkService: MockNetworkService!
    
    override func setUpWithError() throws {
        mockNetworkService = MockNetworkService()
        sut = RepositoryService(networkService: mockNetworkService)
    }
    
    override func tearDownWithError() throws {
        sut = nil
        mockNetworkService = nil
    }
    
    func testGetTrendingRepositories() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch trending repositories")
        let mockRepositories = [
            Repository.placeholder(),
            Repository.placeholder()
        ]
        let mockResponse = SearchRepositoriesResponse(totalCount: mockRepositories.count, incompleteResults: false, items: mockRepositories)
        mockNetworkService.mockResult = MockNetworkService.MockResultType.success(mockResponse)
        
        // When
        sut.getTrendingRepositories(language: "swift", timeSpan: "week", useCache: false) { result in
            // Then
            switch result {
            case .success(let repositories):
                XCTAssertEqual(repositories.count, mockRepositories.count)
            case .failure(let error):
                XCTFail("Request should not fail: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSearchRepositories() {
        // Given
        let expectation = XCTestExpectation(description: "Search repositories")
        let mockRepositories = [
            Repository.placeholder(),
            Repository.placeholder()
        ]
        let mockResponse = SearchRepositoriesResponse(totalCount: mockRepositories.count, incompleteResults: false, items: mockRepositories)
        mockNetworkService.mockResult = MockNetworkService.MockResultType.success(mockResponse)
        
        // When
        sut.searchRepositories(query: "swift", page: 1, perPage: 30, useCache: false) { result in
            // Then
            switch result {
            case .success(let repositories):
                XCTAssertEqual(repositories.count, mockRepositories.count)
            case .failure(let error):
                XCTFail("Request should not fail: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testGetRepositoryDetails() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch repository details")
        let mockRepository = Repository.placeholder()
        mockNetworkService.mockResult = MockNetworkService.MockResultType.success(mockRepository)
        
        // When
        sut.getRepositoryDetails(owner: "apple", name: "swift", useCache: false) { result in
            // Then
            switch result {
            case .success(let repository):
                XCTAssertEqual(repository.id, mockRepository.id)
                XCTAssertEqual(repository.name, mockRepository.name)
            case .failure(let error):
                XCTFail("Request should not fail: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testGetRepositoriesForUser() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch user repositories")
        let mockRepositories = [
            Repository.placeholder(),
            Repository.placeholder()
        ]
        mockNetworkService.mockResult = MockNetworkService.MockResultType.success(mockRepositories)
        
        // When
        sut.getRepositoriesForUser(username: "apple", page: 1, perPage: 30, useCache: false) { result in
            // Then
            switch result {
            case .success(let repositories):
                XCTAssertEqual(repositories.count, mockRepositories.count)
            case .failure(let error):
                XCTFail("Request should not fail: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchRepositoryReadme() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch repository readme")
        let mockReadme = ReadmeResponse(content: "SGVsbG8gV29ybGQh", encoding: "base64") // "Hello World!" in base64
        mockNetworkService.mockResult = MockNetworkService.MockResultType.success(mockReadme)
        
        // When
        sut.fetchRepositoryReadme(owner: "apple", name: "swift") { result in
            // Then
            switch result {
            case .success(let readmeContent):
                XCTAssertEqual(readmeContent, "Hello World!")
            case .failure(let error):
                XCTFail("Request should not fail: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testGetTrendingRepositoriesFailure() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch trending repositories failure")
        mockNetworkService.mockResult = MockNetworkService.MockResultType.failure(NetworkError.networkError)
        
        // When
        sut.getTrendingRepositories(language: "swift", timeSpan: "week", useCache: false) { result in
            // Then
            switch result {
            case .success:
                XCTFail("Request should fail")
            case .failure:
                // Expected
                break
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
} 
