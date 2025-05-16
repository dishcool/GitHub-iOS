//
//  IssueDetailView.swift
//  GitHub
//
//  Created by Dishcool on 2025/5/21.
//

import SwiftUI
import Kingfisher

struct IssueDetailView: View {
    let owner: String
    let repoName: String
    let issueNumber: Int
    
    @StateObject private var viewModel = IssuesViewModel()
    
    var body: some View {
        ScrollView {
            ZStack {
                if viewModel.isLoading {
                    LoadingView(message: "Loading issue details...")
                } else if let errorMessage = viewModel.errorMessage {
                    ErrorView(message: errorMessage) {
                        viewModel.loadIssueDetail(owner: owner, repo: repoName, issueNumber: issueNumber)
                    }
                } else if let issue = viewModel.selectedIssue {
                    VStack(alignment: .leading, spacing: 16) {
                        // Issue title and status
                        HStack(alignment: .center, spacing: 12) {
                            issueStatusBadge(state: issue.state)
                            
                            Text("#\(issue.number)")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text(issue.title)
                                .font(.title2)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(.horizontal)
                        
                        Divider()
                        
                        // Creator and time information
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    KFImage(URL(string: issue.user.avatarUrl))
                                        .placeholder {
                                            Image(systemName: "person.circle.fill")
                                                .foregroundColor(.secondary)
                                        }
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                        .clipShape(Circle())
                                    
                                    Text(issue.user.login)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                }
                                
                                Text("Created on \(formatDate(issue.createdAt))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                if issue.createdAt != issue.updatedAt {
                                    Text("Updated on \(formatDate(issue.updatedAt))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                HStack {
                                    Image(systemName: "message")
                                    Text("\(issue.comments) comments")
                                }
                                .font(.caption)
                                .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Labels list
                        if let labels = issue.labels, !labels.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(labels) { label in
                                        LabelView(label: label)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        Divider()
                        
                        // Issue content
                        if let body = issue.body, !body.isEmpty {
                            VStack(alignment: .leading) {
                                Text(body)
                                    .font(.body)
                                    .multilineTextAlignment(.leading)
                                    .padding(.horizontal)
                            }
                        } else {
                            Text("No description content")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .padding()
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Issue Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadIssueDetail(owner: owner, repo: repoName, issueNumber: issueNumber)
        }
    }
    
    func issueStatusBadge(state: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(state == "open" ? Color.green : Color.purple)
                .frame(width: 10, height: 10)
            
            Text(state == "open" ? "Open" : "Closed")
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(state == "open" ? Color.green.opacity(0.2) : Color.purple.opacity(0.2))
        )
    }
    
    func formatDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        guard let date = dateFormatter.date(from: dateString) else { return "Invalid date" }
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter.string(from: date)
    }
} 