//
//  HomeView.swift
//  GitHub
//
//  Created by Dishcool on 2025/5/15.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    // 常用编程语言列表
    private let languages = ["Swift", "Kotlin", "JavaScript", "Python", "Go", "Rust", "Java", "C++", "TypeScript", "PHP", "Ruby"]
    
    // 时间范围选项
    private let timeSpans = [
        ("day", "今天"),
        ("week", "本周"),
        ("month", "本月"),
        ("year", "今年")
    ]
    
    // 是否显示缓存控制选项
    private let showCacheControl = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 语言过滤器
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
                
                // 时间范围过滤器
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
                
                // API速率限制警告
                if viewModel.showingRateLimitWarning {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.yellow)
                        Text("GitHub API 请求次数已达上限，将使用缓存数据")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.yellow.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }
                
                // 缓存控制
                if showCacheControl {
                    HStack {
                        Toggle("使用缓存", isOn: $viewModel.useCacheForRequests)
                            .toggleStyle(SwitchToggleStyle(tint: .blue))
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.clearAllCaches()
                            viewModel.refreshRepositories()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "trash")
                                Text("清除缓存")
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
                
                // 仓库列表
                if viewModel.isLoading {
                    LoadingView(message: "正在加载热门仓库...")
                        .frame(height: 300)
                } else if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 24) {
                        Spacer()
                            .frame(height: 20)
                        
                        // 错误图标
                        Image(systemName: "exclamationmark.icloud.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.red.opacity(0.8))
                            .padding(.bottom, 10)
                        
                        Text("加载失败")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(errorMessage)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .padding(.bottom, 10)
                        
                        Button(action: {
                            // 重试刷新
                            viewModel.refreshRepositories()
                        }) {
                            HStack {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                Text("重试刷新")
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
                    Text("没有找到符合条件的仓库")
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
        .navigationTitle("热门仓库")
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
