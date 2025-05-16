//
//  MainTabView.swift
//  GitHub
//
//  Created by Dishcool on 2025/5/15.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var selectedTab = 0
    // Add a property to track if we need to refresh the profile
    @State private var needsProfileRefresh = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                HomeView()
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Image(systemName: "house")
                Text("Home")
            }
            .tag(0)
            
            NavigationView {
                SearchView()
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Image(systemName: "magnifyingglass")
                Text("Search")
            }
            .tag(1)
            
            NavigationView {
                if authViewModel.isAuthenticated {
                    // Use a more gentle refreshing approach
                    ProfileView()
                        // This ID will force a rebuild of ProfileView when auth state changes,
                        // but won't cause tab switching
                        .id("profile-\(authViewModel.isAuthenticated)-\(needsProfileRefresh)")
                } else {
                    LoginView()
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Image(systemName: authViewModel.isAuthenticated ? "person" : "person.crop.circle.badge.plus")
                Text(authViewModel.isAuthenticated ? "Profile" : "Login")
            }
            .tag(2)
        }
        // Use a gentler approach to monitor auth changes
        .onChange(of: authViewModel.isAuthenticated) { newValue in
            // Set the flag to trigger a refresh of the profile view
            // This will rebuild the view via the ID modifier, but won't switch tabs
            needsProfileRefresh.toggle()
            
            // If a user just logged in and isn't on the profile tab, navigate there
            if newValue && selectedTab != 2 {
                // Small delay to let auth state settle
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    selectedTab = 2
                }
            }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
} 