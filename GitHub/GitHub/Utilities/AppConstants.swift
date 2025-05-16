//
//  AppConstants.swift
//  GitHub
//
//  Created by Dishcool on 2025/5/17.
//

import Foundation

/// Centralized management of all constants, IDs and keys used in the app
struct AppConstants {
    
    /// GitHub API related constants
    struct GitHub {
        /// GitHub OAuth client ID
        static let clientID = "Ov23lijpUq87uT9pa2yD"
        
        /// GitHub OAuth client secret
        static let clientSecret = "26a8caee7663039413011fb35dde3daf9feedb29"
        
        /// OAuth redirect URI (callback URL)
        /// This should match your GitHub OAuth app configuration
        static let redirectURI = "github20250516junjian://callback"
        
        /// GitHub authorization URL
        static let authorizeUrl = "https://github.com/login/oauth/authorize"
        
        /// GitHub access token URL
        static let accessTokenUrl = "https://github.com/login/oauth/access_token"
        
        /// GitHub API base URL
        static let apiBaseUrl = "https://api.github.com"
        
        /// GitHub API scopes required for the app
        static let scopes = "user repo"
        
        /// GitHub API endpoints
        struct Endpoints {
            /// Get authenticated user profile
            static let user = "/user"
            
            /// Search repositories
            static let searchRepositories = "/search/repositories"
            
            /// Get user repositories
            static let userRepositories = "/users/%@/repos" // %@ = username
            
            /// Get repository details
            static let repository = "/repos/%@/%@" // %@ = owner, %@ = repo name
            
            /// Get repository readme
            static let readme = "/repos/%@/%@/readme" // %@ = owner, %@ = repo name
        }
    }
    
    /// Keychain related constants
    struct Keychain {
        /// Key for storing OAuth token in keychain
        static let tokenKey = "github_oauth_token"
    }
    
    /// Network related constants
    struct Network {
        /// Default cache TTL in seconds
        static let defaultCacheTTL: TimeInterval = 300 // 5 minutes
        
        /// Default timeout for network requests
        static let defaultTimeout: TimeInterval = 30.0
        
        /// Default limit of items per page for paginated requests
        static let defaultItemsPerPage = 30
        
        /// HTTP header keys
        struct Headers {
            /// Authorization header key
            static let authorization = "Authorization"
            
            /// Content-Type header key
            static let contentType = "Content-Type"
            
            /// Accept header key
            static let accept = "Accept"
            
            /// Rate limit remaining header key
            static let rateLimitRemaining = "X-RateLimit-Remaining"
            
            /// Rate limit reset header key
            static let rateLimitReset = "X-RateLimit-Reset"
        }
        
        /// HTTP header values
        struct HeaderValues {
            /// JSON content type
            static let jsonContent = "application/json"
            
            /// Bearer token format
            static let tokenFormat = "token %@" // %@ = token
        }
        
        /// URL query parameters
        struct QueryParams {
            /// Client ID parameter key
            static let clientID = "client_id"
            
            /// Client secret parameter key
            static let clientSecret = "client_secret"
            
            /// Query parameter key
            static let query = "q"
            
            /// Sort parameter key
            static let sort = "sort"
            
            /// Order parameter key
            static let order = "order"
            
            /// Page parameter key
            static let page = "page"
            
            /// Per page parameter key
            static let perPage = "per_page"
        }
    }
    
    /// UI related constants
    struct UI {
        /// Default animation duration
        static let defaultAnimationDuration: TimeInterval = 0.3
        
        /// Standard corner radius for rounded elements
        static let cornerRadius: CGFloat = 10.0
        
        /// Standard padding value
        static let standardPadding: CGFloat = 16.0
        
        /// Standard spacing between elements
        static let standardSpacing: CGFloat = 8.0
        
        /// Icon dimensions
        struct IconSize {
            /// Small icon size
            static let small: CGFloat = 24.0
            
            /// Medium icon size
            static let medium: CGFloat = 44.0
            
            /// Large icon size
            static let large: CGFloat = 100.0
        }
    }
    
    /// System image names
    struct SystemImages {
        /// Home tab icon
        static let home = "house"
        
        /// Search tab icon
        static let search = "magnifyingglass"
        
        /// Profile tab icon (when authenticated)
        static let profile = "person"
        
        /// Login tab icon (when not authenticated)
        static let login = "person.crop.circle.badge.plus"
        
        /// App logo icon
        static let appLogo = "globe"
        
        /// Person icon
        static let person = "person.fill"
        
        /// Face ID icon
        static let faceID = "faceid"
        
        /// Success icon
        static let success = "checkmark.circle.fill"
        
        /// Error icon
        static let error = "exclamationmark.triangle.fill"
        
        /// Right arrow icon
        static let rightArrow = "arrow.right.circle.fill"
    }
} 