//
//  RepositoryDetailView.swift
//  GitHub
//
//  Created by Dishcool on 2025/5/15.
//

import SwiftUI
import Kingfisher
import Down

struct RepositoryDetailView: View {
    @StateObject private var viewModel = RepositoryDetailViewModel()
    
    let owner: String
    let repoName: String
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if viewModel.isLoading {
                    LoadingView(message: "Loading repository information...")
                        .frame(height: 300)
                } else if let repository = viewModel.repository {
                    // Repository basic information
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            KFImage(URL(string: repository.owner.avatarUrl))
                                .placeholder {
                                    Image(systemName: "person.crop.circle")
                                        .resizable()
                                        .foregroundColor(.gray)
                                }
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
                            
                            VStack(alignment: .leading) {
                                Text(repository.owner.login)
                                    .font(.headline)
                                Text(repository.name)
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            
                            Spacer()
                            
                            if repository.isPrivate {
                                HStack(spacing: 4) {
                                    Image(systemName: "lock.fill")
                                    Text("Private")
                                }
                                .font(.caption)
                                .padding(5)
                                .background(Color.red.opacity(0.2))
                                .foregroundColor(.red)
                                .cornerRadius(5)
                            }
                        }
                        
                        if let description = repository.description, !description.isEmpty {
                            Text(description)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .padding(.top, 4)
                        }
                        
                        Divider()
                            .padding(.vertical, 8)
                        
                        // Repository statistics
                        HStack(spacing: 20) {
                            Stat(count: repository.stargazersCount, name: "Stars", icon: "star.fill", color: .yellow)
                            Stat(count: repository.forksCount, name: "Forks", icon: "tuningfork", color: .gray)
                            Stat(count: repository.watchersCount, name: "Watchers", icon: "eye.fill", color: .blue)
                            Stat(count: repository.openIssuesCount, name: "Issues", icon: "exclamationmark.circle.fill", color: .red)
                        }
                        .padding(.vertical, 8)
                        
                        // Repository additional information
                        VStack(alignment: .leading, spacing: 8) {
                            if let language = repository.language {
                                HStack {
                                    Circle()
                                        .fill(languageColor(language))
                                        .frame(width: 12, height: 12)
                                    Text(language)
                                        .font(.subheadline)
                                }
                            }
                            
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(.gray)
                                Text("Created on \(formattedDate(repository.createdAt))")
                                    .font(.subheadline)
                            }
                            
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                    .foregroundColor(.gray)
                                Text("Last updated on \(formattedDate(repository.updatedAt))")
                                    .font(.subheadline)
                            }
                        }
                        
                        // Add buttons for viewing code and issues
                        HStack(spacing: 12) {
                            NavigationLink(
                                destination: WebViewPage(
                                    url: URL(string: "https://github.com/\(owner)/\(repoName)")!,
                                    title: "Code Directory"
                                )
                            ) {
                                HStack {
                                    Image(systemName: "doc.text.fill")
                                    Text("View Code")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            
                            NavigationLink(
                                destination: IssuesListView(owner: owner, repoName: repoName)
                            ) {
                                HStack {
                                    Image(systemName: "exclamationmark.circle.fill")
                                    Text("View Issues")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                        }
                        .padding(.top, 8)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // README
                    VStack(alignment: .leading, spacing: 12) {
                        Text("README")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        if viewModel.isLoadingReadme {
                            LoadingView(message: "Loading README...")
                                .frame(height: 200)
                        } else if let readme = viewModel.readme {
                            if #available(iOS 15, *) {
                                Text(AttributedString(readme))
                                    .padding()
                            } else {
                                Text(readme.string)
                                    .padding()
                            }
                        } else {
                            Text("Failed to load README or this repository doesn't contain a README file")
                                .foregroundColor(.secondary)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                } else if let error = viewModel.error {
                    Text("Loading failed: \(error.localizedDescription)")
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .padding(.vertical)
        }
        .navigationTitle(repoName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadRepositoryDetails(owner: owner, name: repoName)
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func languageColor(_ language: String) -> Color {
        switch language.lowercased() {
        case "swift":
            return .orange
        case "objective-c":
            return .blue
        case "kotlin":
            return .purple
        case "java":
            return .red
        case "javascript":
            return .yellow
        case "typescript":
            return .blue
        case "python":
            return .green
        case "ruby":
            return .red
        case "go":
            return .orange
        case "rust":
            return .blue
        case "c++", "c":
            return .purple
        case "c#":
            return .red
        case "php":
            return .yellow
        default:
            return .gray
        }
    }
}

struct Stat: View {
    let count: Int
    let name: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text("\(count)")
                    .font(.headline)
            }
            Text(name)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    NavigationView {
        RepositoryDetailView(owner: "apple", repoName: "swift")
    }
} 
