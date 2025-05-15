//
//  ProfileView.swift
//  GitHub
//
//  Created by Dishcool on 2025/5/15.
//

import SwiftUI
import Kingfisher

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var isRefreshing = false
    @State private var previousScrollOffset: CGFloat = 0
    
    var username: String?
    
    var body: some View {
        ScrollView {
            GeometryReader { geometry in
                Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .global).minY)
            }
            .frame(height: 0)
            
            // 显示刷新指示器
            if isRefreshing {
                HStack {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                    Spacer()
                }
                .padding(.top)
            }
            
            VStack(spacing: 20) {
                if viewModel.isLoadingUser {
                    LoadingView(message: "加载用户信息...")
                        .frame(height: 200)
                } else if let user = viewModel.user {
                    // 用户信息
                    VStack(spacing: 12) {
                        KFImage(URL(string: user.avatarUrl))
                            .placeholder {
                                Image(systemName: "person.crop.circle")
                                    .resizable()
                                    .foregroundColor(.gray)
                            }
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
                        
                        Text(user.name ?? user.login)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("@\(user.login)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if let bio = user.bio, !bio.isEmpty {
                            Text(bio)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        HStack(spacing: 30) {
                            VStack {
                                Text("\(user.followers ?? 0)")
                                    .font(.headline)
                                Text("粉丝")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack {
                                Text("\(user.following ?? 0)")
                                    .font(.headline)
                                Text("关注")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack {
                                Text("\(user.publicRepos ?? 0)")
                                    .font(.headline)
                                Text("仓库")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.top, 8)
                        
                        // 用户其他信息
                        VStack(alignment: .leading, spacing: 8) {
                            if let location = user.location, !location.isEmpty {
                                HStack {
                                    Image(systemName: "location.fill")
                                        .foregroundColor(.gray)
                                    Text(location)
                                }
                            }
                            
                            if let email = user.email, !email.isEmpty {
                                HStack {
                                    Image(systemName: "envelope.fill")
                                        .foregroundColor(.gray)
                                    Text(email)
                                }
                            }
                        }
                        .padding(.top, 8)
                        
                        // 登出按钮（仅当查看自己的资料时显示）
                        if authViewModel.currentUser?.id == user.id {
                            Button(action: {
                                authViewModel.logout()
                            }) {
                                Text("退出登录")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.red)
                                    .cornerRadius(10)
                                    .padding(.horizontal)
                            }
                            .padding(.top, 20)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // 仓库列表
                    VStack(alignment: .leading) {
                        Text("仓库")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        if viewModel.isLoadingRepos {
                            LoadingView(message: "加载仓库...")
                                .frame(height: 150)
                        } else if viewModel.repositories.isEmpty {
                            Text("没有公开的仓库")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else {
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.repositories) { repository in
                                    NavigationLink(destination: RepositoryDetailView(owner: repository.owner.login, repoName: repository.name)) {
                                        RepositoryCard(repository: repository, showOwner: false)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)
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
        .navigationTitle(username != nil ? username! : "我的资料")
        .onAppear {
            if let username = username {
                viewModel.loadUserProfile(username: username)
            } else if let currentUser = authViewModel.currentUser {
                viewModel.user = currentUser
                viewModel.loadUserRepositories(username: currentUser.login)
            }
        }
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
            // 检测下拉刷新
            if value > 70 && !isRefreshing && value > previousScrollOffset {
                isRefreshing = true
                refresh()
            }
            previousScrollOffset = value
        }
    }
    
    // 刷新函数
    private func refresh() {
        viewModel.refresh()
        
        // 模拟刷新延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isRefreshing = false
        }
    }
}

// ScrollOffset Preference Key for tracking scroll position
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    NavigationView {
        ProfileView()
            .environmentObject(AuthViewModel())
    }
} 