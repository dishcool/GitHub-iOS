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
                    LoadingView(message: "加载仓库信息...")
                        .frame(height: 300)
                } else if let repository = viewModel.repository {
                    // 仓库基本信息
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
                                Label("私有", systemImage: "lock.fill")
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
                        
                        // 仓库统计信息
                        HStack(spacing: 20) {
                            Stat(count: repository.stargazersCount, name: "星标", icon: "star.fill", color: .yellow)
                            Stat(count: repository.forksCount, name: "分叉", icon: "tuningfork", color: .gray)
                            Stat(count: repository.watchersCount, name: "观察", icon: "eye.fill", color: .blue)
                            Stat(count: repository.openIssuesCount, name: "问题", icon: "exclamationmark.circle.fill", color: .red)
                        }
                        .padding(.vertical, 8)
                        
                        // 仓库其他信息
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
                                Text("创建于 \(formattedDate(repository.createdAt))")
                                    .font(.subheadline)
                            }
                            
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                    .foregroundColor(.gray)
                                Text("最后更新于 \(formattedDate(repository.updatedAt))")
                                    .font(.subheadline)
                            }
                        }
                        
                        // 在浏览器中打开链接按钮
                        Button(action: {
                            if let url = URL(string: repository.htmlUrl) {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            HStack {
                                Image(systemName: "safari")
                                Text("在浏览器中打开")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
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
                            LoadingView(message: "加载README...")
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
                            Text("无法加载README或该仓库不包含README文件")
                                .foregroundColor(.secondary)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                } else if let error = viewModel.error {
                    Text("加载失败: \(error.localizedDescription)")
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
