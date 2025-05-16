//
//  GitHubApp.swift
//  GitHub
//
//  Created by Jacky Lam on 2025/5/15.
//

import SwiftUI
import OAuthSwift

@main
struct GitHubApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(authViewModel)
                .onOpenURL { url in
                    // This is where the App captures the callback URL
                    OAuthSwift.handle(url: url)
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    // Check loading state when the app is reactivated
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        authViewModel.resetLoadingState()
                    }
                }
        }
    }
} 
