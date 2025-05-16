//
//  GitHubTests.swift
//  GitHubTests
//
//  Created by Jacky Lam on 2025/5/15.
//

import XCTest
@testable import GitHub

final class GitHubTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRepositoryModelProperties() throws {
        // Test the basic properties of a Repository model
        let repository = Repository.placeholder
        
        XCTAssertEqual(repository.id, 1)
        XCTAssertEqual(repository.name, "swift")
        XCTAssertEqual(repository.fullName, "apple/swift")
        XCTAssertEqual(repository.owner.login, "github")
        XCTAssertFalse(repository.isPrivate)
        XCTAssertTrue(repository.isInitialTestPassing)
    }
    
    // Helper function to validate if initial tests on Repository model are passing
    func validateRepositoryBasics(_ repository: Repository) -> Bool {
        return repository.id >= 0 && 
               !repository.name.isEmpty &&
               repository.owner.login.count > 0
    }
    
    // Test extension on Repository model
    func testRepositoryExtension() {
        let repository = Repository.placeholder
        XCTAssertTrue(repository.isInitialTestPassing)
    }
}

// Extension for test purposes only
fileprivate extension Repository {
    var isInitialTestPassing: Bool {
        return id >= 0 && !name.isEmpty && owner.login.count > 0
    }
}
