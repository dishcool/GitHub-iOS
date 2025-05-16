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
            
            // Display refresh indicator
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
                    LoadingView(message: "Loading user information...")
                        .frame(height: 200)
                } else if let user = viewModel.user {
                    // User information
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
                                Text("Followers")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack {
                                Text("\(user.following ?? 0)")
                                    .font(.headline)
                                Text("Following")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack {
                                Text("\(user.publicRepos ?? 0)")
                                    .font(.headline)
                                Text("Repositories")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.top, 8)
                        
                        // User additional information
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
                        
                        // Logout button (only shown when viewing your own profile)
                        if authViewModel.currentUser?.id == user.id {
                            Button(action: {
                                authViewModel.logout()
                            }) {
                                Text("Log Out")
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
                    
                    // Repository list
                    VStack(alignment: .leading) {
                        Text("Repositories")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        if viewModel.isLoadingRepos {
                            LoadingView(message: "Loading repositories...")
                                .frame(height: 150)
                        } else if viewModel.repositories.isEmpty {
                            Text("No public repositories")
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
                    Text("Loading failed: \(error.localizedDescription)")
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .padding(.vertical)
        }
        .navigationTitle(username != nil ? username! : "My Profile")
        .onAppear {
            if let username = username {
                viewModel.loadUserProfile(username: username)
            } else if let currentUser = authViewModel.currentUser {
                viewModel.user = currentUser
                viewModel.loadUserRepositories(username: currentUser.login)
            }
        }
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
            // Detect pull-to-refresh
            if value > 70 && !isRefreshing && value > previousScrollOffset {
                isRefreshing = true
                refresh()
            }
            previousScrollOffset = value
        }
    }
    
    // Refresh function
    private func refresh() {
        viewModel.refresh()
        
        // Simulate refresh delay
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