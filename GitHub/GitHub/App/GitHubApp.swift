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
                    // 这里是 App 捕捉回调 URL 的地方
                    OAuthSwift.handle(url: url)
                }
        }
        
    }
} 
