//
//  SearchView.swift
//  GitHub
//
//  Created by Dishcool on 2025/5/15.
//

import SwiftUI
import Kingfisher

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    
    var body: some View {
        VStack {
            // 搜索栏
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("搜索GitHub", text: $viewModel.searchQuery)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                if !viewModel.searchQuery.isEmpty {
                    Button(action: {
                        viewModel.searchQuery = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
            
            // 分段控制器
            Picker("Search Type", selection: $viewModel.selectedSegment) {
                ForEach(SearchSegment.allCases, id: \.self) { segment in
                    Text(segment.title).tag(segment)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            .onChange(of: viewModel.selectedSegment) { _ in
                if !viewModel.searchQuery.isEmpty {
                    viewModel.performSearch(query: viewModel.searchQuery)
                }
            }
            
            // 搜索结果
            if viewModel.isLoading {
                LoadingView(message: "正在搜索...")
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        switch viewModel.selectedSegment {
                        case .repositories:
                            if viewModel.repositories.isEmpty && !viewModel.searchQuery.isEmpty {
                                Text("未找到匹配的仓库")
                                    .foregroundColor(.secondary)
                                    .padding()
                            } else {
                                ForEach(viewModel.repositories) { repository in
                                    NavigationLink(destination: RepositoryDetailView(owner: repository.owner.login, repoName: repository.name)) {
                                        RepositoryCard(repository: repository)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            
                        case .users:
                            if viewModel.users.isEmpty && !viewModel.searchQuery.isEmpty {
                                Text("未找到匹配的用户")
                                    .foregroundColor(.secondary)
                                    .padding()
                            } else {
                                ForEach(viewModel.users) { user in
                                    NavigationLink(destination: ProfileView(username: user.login)) {
                                        UserRow(user: user)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            
                        case .organizations:
                            if viewModel.organizations.isEmpty && !viewModel.searchQuery.isEmpty {
                                Text("未找到匹配的组织")
                                    .foregroundColor(.secondary)
                                    .padding()
                            } else {
                                ForEach(viewModel.organizations) { org in
                                    NavigationLink(destination: ProfileView(username: org.login)) {
                                        UserRow(user: org)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("搜索")
    }
}

struct UserRow: View {
    let user: User
    
    var body: some View {
        HStack(spacing: 12) {
            KFImage(URL(string: user.avatarUrl))
                .placeholder {
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .foregroundColor(.gray)
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(user.login)
                    .font(.headline)
                
                if let name = user.name {
                    Text(name)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}

#Preview {
    NavigationView {
        SearchView()
    }
} 