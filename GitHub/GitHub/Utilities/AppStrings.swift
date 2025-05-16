//
//  AppStrings.swift
//  GitHub
//
//  Created by Dishcool on 2025/5/17.
//

import Foundation

/// Centralized management of all string constants used in the app
struct AppStrings {
    
    /// Authentication related strings
    struct Auth {
        /// App title displayed on login screen
        static let appTitle = "GitHub iOS Client"
        
        /// App subtitle displayed on login screen
        static let appSubtitle = "Explore the world of GitHub"
        
        /// Login with GitHub account button text
        static let loginWithGitHub = "Login with GitHub Account"
        
        /// Login with biometric (Face ID / Touch ID) button text
        static let loginWithBiometric = "Login with Face ID / Touch ID"
        
        /// One-tap auto login button text (for simulator)
        static let loginAutoSimulator = "One-tap Auto Login"
        
        /// Login reason for biometric authentication
        static let biometricReason = "Log in to your GitHub account"
        
        /// Loading message during login
        static let loggingIn = "Logging in..."
        
        /// Login failed alert title
        static let loginFailedTitle = "Login Failed"
        
        /// OK button text
        static let ok = "OK"
        
        /// Message when automatically logging in on simulator
        static let simulatorAutoLogin = "[Auth] Detected simulator environment with saved token, automatically logging in with token"
        
        /// Error messages
        struct ErrorMessages {
            /// Token not found error message
            static let tokenNotFound = "Login credentials not found, please use GitHub account to log in"
            
            /// Authorization failed error message
            static let authFailed = "GitHub authorization failed, please try again later"
            
            /// Network error message
            static let networkError = "Network connection error, please check your network settings"
            
            /// Biometric not available error message
            static let biometricNotAvailable = "Biometric authentication unavailable, please use GitHub account to log in"
            
            /// Unknown error message
            static let unknownError = "Unknown error, please try again later"
        }
        
        /// Log messages
        struct Logs {
            /// Auto check login message
            static let autoCheckLogin = "[Auth] Application launch, detected simulator environment with saved token, automatically checking login status"
            
            /// Auto login message
            static let autoLogin = "[Auth] Detected simulator environment with saved token, skipping biometric authentication and trying to login directly"
        }
    }
    
    /// TabBar item titles
    struct TabBar {
        /// Home tab title
        static let home = "Home"
        
        /// Search tab title
        static let search = "Search"
        
        /// Profile tab title when authenticated
        static let profile = "Profile"
        
        /// Login tab title when not authenticated
        static let login = "Login"
    }
    
    /// Network related strings
    struct Network {
        /// Log format for API requests
        static let requestLog = "🌐 API Request: %@ %@"
        
        /// Log format for headers
        static let headersLog = "🔑 Headers: %@"
        
        /// Log format for parameters
        static let parametersLog = "📦 Parameters: %@"
        
        /// Log format for using client credentials
        static let clientCredentialsLog = "📝 Using client credentials for unauthenticated request"
        
        /// Log format for response
        static let responseLog = "[Network] Response: %d, Rate Limit Remaining: %@, Reset: %@"
        
        /// Log format for response data
        static let responseDataLog = "📄 Response Data: %@..."
        
        /// Log format for API error
        static let apiErrorLog = "⚠️ API Error: %@"
        
        /// Log format for error parsing JSON
        static let errorParsingJsonLog = "❌ Error parsing JSON error response"
        
        /// Log format for decoding error
        static let decodingErrorLog = "❌ Decoding Error: %@"
        
        /// Log format for error data
        static let errorDataLog = "❌ Error data: %@"
        
        /// Log format for network error
        static let networkErrorLog = "❌ Network Error: %@"
    }
    
    /// Cache related strings
    struct Cache {
        /// Log message for using cached response
        static let usingCachedResponse = "🧩 Using cached response for: %@"
        
        /// Log message for failed decoding of cached response
        static let failedDecoding = "⚠️ Failed to decode cached response: %@"
        
        /// Log message for expired cache
        static let cacheExpired = "⏱️ Cache expired for: %@"
        
        /// Log message for stored in cache
        static let storedInCache = "💾 Cached response for key: %@"
        
        /// Log message for removed from cache
        static let removedFromCache = "🧹 Removed cache for key: %@"
        
        /// Log message for cleared all cache
        static let clearedAllCache = "🧹 Cleared all cached responses"
        
        /// Log message for removed expired entries
        static let removedExpiredEntries = "⏱️ Removed %d expired cache entries"
    }
} 