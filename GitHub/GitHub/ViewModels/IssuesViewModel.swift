//
//  IssuesViewModel.swift
//  GitHub
//
//  Created by Dishcool on 2025/5/21.
//

import Foundation
import Combine

class IssuesViewModel: ObservableObject {
    @Published var issues: [Issue] = []
    @Published var selectedIssue: Issue?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let issuesService: IssuesServiceProtocol
    
    init(issuesService: IssuesServiceProtocol = IssuesService()) {
        self.issuesService = issuesService
    }
    
    func loadIssues(owner: String, repo: String) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetchedIssues = try await issuesService.getIssues(owner: owner, repo: repo)
                await MainActor.run {
                    self.issues = fetchedIssues
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "加载Issues失败: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    func loadIssueDetail(owner: String, repo: String, issueNumber: Int) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let issue = try await issuesService.getIssueDetail(owner: owner, repo: repo, issueNumber: issueNumber)
                await MainActor.run {
                    self.selectedIssue = issue
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "加载Issue详情失败: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
} 