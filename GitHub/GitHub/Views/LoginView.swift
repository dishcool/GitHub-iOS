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
    
    // Detect if running in simulator environment
    private var isRunningOnSimulator: Bool {
        #if targetEnvironment(simulator)
            return true  // Enable auto-login in simulator environment
        #else
            return false
        #endif
    }
    
    var body: some View {
        VStack(spacing: 30) {
            // Logo and Title
            VStack(spacing: 20) {
                Image(systemName: "globe")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.accentColor)
                
                Text("GitHub iOS Client")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Explore the world of GitHub")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 50)
            
            // Display prompt in simulator environment
            if isRunningOnSimulator && hasToken {
                VStack(spacing: 8) {
                    Text("Simulator Environment Detected")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    Text("Existing accounts will auto-login without biometric authentication")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.blue.opacity(0.1))
                )
                .padding(.horizontal, 30)
            }
            
            Spacer()
            
            // Login Buttons
            VStack(spacing: 20) {
                // Only show GitHub account login button for users who haven't logged in before
                if !hasToken {
                    Button(action: {
                        authViewModel.login()
                    }) {
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(.white)
                            
                            Text("Login with GitHub Account")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .cornerRadius(10)
                    }
                }
                
                // For simulator environment, show one-tap auto-login button when token exists
                if isRunningOnSimulator && hasToken {
                    Button(action: {
                        authViewModel.authenticateWithBiometric()
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.circle.fill")
                                .foregroundColor(.white)
                            
                            Text("One-tap Auto Login")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                    }
                }
                // On physical devices, show biometric login button when token exists
                else if hasToken {
                    Button(action: {
                        authViewModel.authenticateWithBiometric()
                    }) {
                        HStack {
                            Image(systemName: "faceid")
                                .foregroundColor(.accentColor)
                            
                            Text("Login with Face ID / Touch ID")
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
                    LoadingView(message: "Logging in...")
                }
            }
        )
        .alert(item: Binding<AuthError?>(
            get: { self.authViewModel.error != nil ? AuthError(error: self.authViewModel.error!) : nil },
            set: { _ in self.authViewModel.error = nil }
        )) { authError in
            Alert(
                title: Text("Login Failed"),
                message: Text(authError.message),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            // Use AuthViewModel's hasToken method to check for previous login records
            self.hasToken = authViewModel.hasToken()
            
            // Check and reset potential pending loading state
            authViewModel.resetLoadingState()
        }
        .onDisappear {
            // Immediately reset loading state when login page disappears
            // This handles cases where user taps login button then returns via gesture or cancels OAuth authorization
            authViewModel.resetLoadingState()
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
                return "Login credentials not found, please use GitHub account to log in"
            case .authorizationFailed:
                return "GitHub authorization failed, please try again later"
            case .networkError:
                return "Network connection error, please check your network settings"
            case .biometricNotAvailable:
                return "Biometric authentication unavailable, please use GitHub account to log in"
            case .unknownError:
                return "Unknown error, please try again later"
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
