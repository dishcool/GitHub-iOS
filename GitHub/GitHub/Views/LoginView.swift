//
//  LoginView.swift
//  GitHub
//
//  Created by Dishcool on 2025/5/15.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var hasToken: Bool = false
    
    var body: some View {
        VStack(spacing: 30) {
            // Logo and Title
            VStack(spacing: 20) {
                Image(systemName: "globe")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.accentColor)
                
                Text("GitHub iOS客户端")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("探索GitHub的世界")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 50)
            
            Spacer()
            
            // Login Buttons
            VStack(spacing: 20) {
                // 只有之前未登录过的用户会显示GitHub账号登录按钮
                if !hasToken {
                    Button(action: {
                        authViewModel.login()
                    }) {
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(.white)
                            
                            Text("GitHub账号登录")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .cornerRadius(10)
                    }
                }
                
                // 只有之前登录过的用户会显示生物识别登录按钮
                if hasToken {
                    Button(action: {
                        authViewModel.authenticateWithBiometric()
                    }) {
                        HStack {
                            Image(systemName: "faceid")
                                .foregroundColor(.accentColor)
                            
                            Text("Face ID / Touch ID登录")
                                .font(.headline)
                                .foregroundColor(.accentColor)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 50)
        }
        .overlay(
            Group {
                if authViewModel.isLoading {
                    LoadingView(message: "正在登录...")
                }
            }
        )
        .alert(item: Binding<AuthError?>(
            get: { self.authViewModel.error != nil ? AuthError(error: self.authViewModel.error!) : nil },
            set: { _ in self.authViewModel.error = nil }
        )) { authError in
            Alert(
                title: Text("登录失败"),
                message: Text(authError.message),
                dismissButton: .default(Text("确定"))
            )
        }
        .onAppear {
            // 使用 AuthViewModel 的 hasToken 方法检查是否有之前的登录记录
            self.hasToken = authViewModel.hasToken()
        }
    }
}

struct AuthError: Identifiable {
    let id = UUID()
    let error: Error
    
    var message: String {
        switch error {
        case is AuthenticationError:
            let authError = error as! AuthenticationError
            switch authError {
            case .tokenNotFound:
                return "未找到登录凭证，请使用GitHub账号登录"
            case .authorizationFailed:
                return "GitHub授权失败，请稍后重试"
            case .networkError:
                return "网络连接错误，请检查网络设置"
            case .biometricNotAvailable:
                return "生物识别不可用，请使用GitHub账号登录"
            case .unknownError:
                return "未知错误，请稍后重试"
            }
        default:
            return error.localizedDescription
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
} 