//
//  GitHubApp.swift
//  GitHub
//
//  Created by Jacky Lam on 2025/5/15.
//

import SwiftUI

@main
struct GitHubApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(authViewModel)
        }
    }
} 