//
//  HomeView.swift
//  GitHub
//
//  Created by Dishcool on 2025/5/15.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    // Common programming languages list
    private let languages = ["Swift", "Kotlin", "JavaScript", "Python", "Go", "Rust", "Java", "C++", "TypeScript", "PHP", "Ruby"]
    
    // Time range options
    private let timeSpans = [
        ("day", "Today"),
        ("week", "This Week"),
        ("month", "This Month"),
        ("year", "This Year")
    ]
    
    // Whether to show cache control options
    private let showCacheControl = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Language filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        Button(action: {
                            viewModel.selectedLanguage = ""
                        }) {
                            Text("All")
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(viewModel.selectedLanguage.isEmpty ? Color.accentColor : Color.gray.opacity(0.2))
                                .foregroundColor(viewModel.selectedLanguage.isEmpty ? .white : .primary)
                                .cornerRadius(16)
                        }
                        
                        ForEach(languages, id: \.self) { language in
                            Button(action: {
                                viewModel.selectedLanguage = language
                            }) {
                                Text(language)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(viewModel.selectedLanguage == language ? Color.accentColor : Color.gray.opacity(0.2))
                                    .foregroundColor(viewModel.selectedLanguage == language ? .white : .primary)
                                    .cornerRadius(16)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Time range filter
                HStack(spacing: 16) {
                    ForEach(timeSpans, id: \.0) { timeSpan in
                        Button(action: {
                            viewModel.selectedTimeSpan = timeSpan.0
                        }) {
                            Text(timeSpan.1)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(viewModel.selectedTimeSpan == timeSpan.0 ? Color.accentColor : Color.gray.opacity(0.2))
                                .foregroundColor(viewModel.selectedTimeSpan == timeSpan.0 ? .white : .primary)
                                .cornerRadius(16)
                        }
                    }
                }
                .padding(.horizontal)
                
                // API rate limit warning
                if viewModel.showingRateLimitWarning {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.yellow)
                        Text("GitHub API request limit reached, will use cached data")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.yellow.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }
                
                // Cache control
                if showCacheControl {
                    HStack {
                        Toggle("Use Cache", isOn: $viewModel.useCacheForRequests)
                            .toggleStyle(SwitchToggleStyle(tint: .blue))
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.clearAllCaches()
                            viewModel.refreshRepositories()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "trash")
                                Text("Clear Cache")
                                    .font(.footnote)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .padding(.horizontal)
                }
                
                // Repository list
                if viewModel.isLoading {
                    LoadingView(message: "Loading trending repositories...")
                        .frame(height: 300)
                } else if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 24) {
                        Spacer()
                            .frame(height: 20)
                        
                        // Error icon
                        Image(systemName: "exclamationmark.icloud.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.red.opacity(0.8))
                            .padding(.bottom, 10)
                        
                        Text("Load failed")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(errorMessage)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .padding(.bottom, 10)
                        
                        Button(action: {
                            // Retry refresh
                            viewModel.refreshRepositories()
                        }) {
                            HStack {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                Text("Retry Refresh")
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.blue)
                            )
                            .foregroundColor(.white)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        
                        Spacer()
                            .frame(height: 20)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 50)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    )
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                } else if viewModel.repositories.isEmpty {
                    Text("No repositories found that match the criteria")
                        .foregroundColor(.secondary)
                        .padding(.top, 50)
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.repositories) { repository in
                            NavigationLink(destination: RepositoryDetailView(owner: repository.owner.login, repoName: repository.name)) {
                                RepositoryCard(repository: repository)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Trending Repositories")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    viewModel.refreshRepositories()
                }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .onAppear {
            if viewModel.repositories.isEmpty && viewModel.errorMessage == nil {
                viewModel.fetchTrendingRepositories()
            }
        }
    }
}

#Preview {
    NavigationView {
        HomeView()
    }
} 
