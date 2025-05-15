//
//  MainTabView.swift
//  GitHub
//
//  Created by Dishcool on 2025/5/15.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    var body: some View {
        TabView {
            NavigationView {
                HomeView()
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Label("Home", systemImage: "house")
            }
            
            NavigationView {
                SearchView()
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }
            
            NavigationView {
                if authViewModel.isAuthenticated {
                    ProfileView()
                } else {
                    LoginView()
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Label(authViewModel.isAuthenticated ? "Profile" : "Login", 
                      systemImage: authViewModel.isAuthenticated ? "person" : "person.crop.circle.badge.plus")
            }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
} 