//
//  RepositoryDetailViewModel.swift
//  GitHub
//
//  Created by Dishcool on 2025/5/15.
//

import Foundation
import UIKit
import Combine
import Down

class RepositoryDetailViewModel: ObservableObject {
    @Published var repository: Repository?
    @Published var isLoading: Bool = false
    @Published var error: Error?
    @Published var readme: NSAttributedString?
    @Published var isLoadingReadme: Bool = false
    
    private let repositoryService: RepositoryServiceProtocol
    private let networkService: NetworkServiceProtocol
    
    init(repository: Repository? = nil,
         repositoryService: RepositoryServiceProtocol = RepositoryService(),
         networkService: NetworkServiceProtocol = NetworkService()) {
        self.repository = repository
        self.repositoryService = repositoryService
        self.networkService = networkService
    }
    
    func loadRepositoryDetails(owner: String, name: String) {
        isLoading = true
        error = nil
        
        repositoryService.getRepositoryDetails(owner: owner, name: name, useCache: true) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let repository):
                    self?.repository = repository
                    self?.loadReadme(owner: owner, name: name)
                case .failure(let error):
                    self?.error = error
                }
            }
        }
    }
    
    func loadReadme(owner: String, name: String) {
        isLoadingReadme = true
        
        // GitHub API endpoint for fetching README content
        let endpoint = "https://api.github.com/repos/\(owner)/\(name)/readme"
        
        networkService.request(endpoint: endpoint, method: .get) { [weak self] (result: Result<DetailedReadmeResponse, Error>) in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoadingReadme = false
                switch result {
                case .success(let response):
                    // Decode base64 content
                    if let data = Data(base64Encoded: response.content, options: .ignoreUnknownCharacters),
                       let decodedReadme = String(data: data, encoding: .utf8) {
                        let down = Down(markdownString: decodedReadme)
                        self.readme = try? down.toAttributedString(styler: self.markdownStyler)
                    } else {
                        self.readme = NSAttributedString.init(string: "Unable to decode README content.")
                    }
                case .failure(let error):
                    self.error = error
                    self.readme = NSAttributedString.init(string: "No README available for this repository.")
                }
            }
        }
    }
    
    lazy var markdownStyler: DownStyler = {

        var paragraphStyle = StaticParagraphStyleCollection.init()
        
        let types = [paragraphStyle.body, paragraphStyle.heading1, paragraphStyle.heading2, paragraphStyle.heading3, paragraphStyle.heading4, paragraphStyle.heading5, paragraphStyle.heading6]
        types.forEach { style in
            (style as? NSMutableParagraphStyle)?.paragraphSpacing = 30
            (style as? NSMutableParagraphStyle)?.lineSpacing = 20
            (style as? NSMutableParagraphStyle)?.paragraphSpacingBefore = 30
        }

        let configuration = DownStylerConfiguration.init(paragraphStyles: paragraphStyle)

        return DownStyler(configuration: configuration)
    }()
}

struct DetailedReadmeResponse: Codable {
    let name: String
    let path: String
    let content: String
    let encoding: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case path
        case content
        case encoding
    }
} 

