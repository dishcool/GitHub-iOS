//
//  NetworkService.swift
//  GitHub
//
//  Created by Dishcool on 2025/5/15.
//

import Foundation
import Alamofire
import SwiftyJSON

/// Service for making network requests to the GitHub API
class NetworkService: NetworkServiceProtocol {
    // GitHub OAuth credentials for unauthenticated requests
    private let clientID = "Ov23lijpUq87uT9pa2yD"
    private let clientSecret = "26a8caee7663039413011fb35dde3daf9feedb29"
    
    /// Default headers to include in all requests
    private var defaultHeaders: [String: String] {
        var headers = [
            "Accept": "application/json"
        ]
        
        // Get token from KeychainService instead of hardcoded value
        if let token = KeychainService.shared.retrieveToken(), !token.isEmpty {
            headers["Authorization"] = "token \(token)"
        }
        
        return headers
    }
    
    // Use our new cache implementation
    private let cache: NetworkCacheProtocol
    
    // Cache time-to-live (seconds)
    private let cacheTTL: TimeInterval = 300 // 5 minutes
    
    private let session: Session
    
    /// Initialize the network service
    /// - Parameters:
    ///   - session: Alamofire session for making requests
    ///   - cache: Cache implementation to use
    init(session: Session = .default, cache: NetworkCacheProtocol = InMemoryNetworkCache.shared) {
        self.session = session
        self.cache = cache
    }
    
    /// Make a network request with full parameter control
    /// - Parameters:
    ///   - endpoint: The API endpoint URL
    ///   - method: The HTTP method to use
    ///   - parameters: Optional parameters to include in the request
    ///   - headers: Optional headers to include in the request
    ///   - useCache: Whether to use cached responses for GET requests
    ///   - completion: Callback with the result containing the decoded response or an error
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        parameters: [String: Any]?,
        headers: [String: String]?,
        useCache: Bool = true,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let url = URL(string: endpoint) else {
            completion(.failure(NetworkError.invalidEndpoint))
            return
        }
        
        // For GET requests, try to retrieve from cache
        if method == .get && useCache {
            let cacheKey = "\(endpoint)_\(parameters?.description ?? "")"
            
            if let cachedEntry = cache.retrieve(forKey: cacheKey) {
                // Check if cache is expired
                if Date().timeIntervalSince(cachedEntry.timestamp) < cacheTTL {
                    do {
                        // Try to decode from cache
                        let decodedObject = try JSONDecoder().decode(T.self, from: cachedEntry.data)
                        print("🧩 Using cached response for: \(endpoint)")
                        completion(.success(decodedObject))
                        return
                    } catch {
                        print("⚠️ Failed to decode cached response: \(error)")
                        // Cache decoding failed, continue with network request
                    }
                } else {
                    print("⏱️ Cache expired for: \(endpoint)")
                    // Expired cache entry should be removed
                    cache.remove(forKey: cacheKey)
                }
            }
        }
        
        let allHeaders = defaultHeaders.merging(headers ?? [:]) { (_, new) in new }
        
        print("🌐 API Request: \(method.rawValue) \(endpoint)")
        print("🔑 Headers: \(allHeaders.filter { $0.key != "Authorization" })")
        if let parameters = parameters {
            print("📦 Parameters: \(parameters)")
        }
        
        // Determine if we're making an authenticated request
        let isAuthenticated = allHeaders["Authorization"] != nil
        
        // For unauthenticated requests to GitHub API, add client_id and client_secret as parameters
        var finalParameters = parameters ?? [:]
        if !isAuthenticated && endpoint.contains("api.github.com") {
            // Only add client credentials for GitHub API requests
            var urlComponents = URLComponents(string: endpoint)
            
            // Add client_id and client_secret to URL for GET requests
            if method == .get {
                var queryItems = urlComponents?.queryItems ?? []
                queryItems.append(URLQueryItem(name: "client_id", value: clientID))
                queryItems.append(URLQueryItem(name: "client_secret", value: clientSecret))
                urlComponents?.queryItems = queryItems
                
                if let newURL = urlComponents?.url {
                    print("📝 Using client credentials for unauthenticated request")
                    AF.request(
                        newURL,
                        method: alamofireMethod(from: method),
                        parameters: finalParameters,
                        encoding: URLEncoding.default,
                        headers: HTTPHeaders(allHeaders)
                    ).responseData { [weak self] response in
                        self?.handleResponse(response: response, 
                                          url: newURL, 
                                          method: method, 
                                          cacheKey: "\(newURL.absoluteString)_\(finalParameters.description)", 
                                          useCache: useCache, 
                                          completion: completion)
                    }
                    return
                }
            } else {
                // For non-GET requests, add client_id and client_secret to the parameters
                finalParameters["client_id"] = clientID
                finalParameters["client_secret"] = clientSecret
                print("📝 Using client credentials for unauthenticated request")
            }
        }
        
        let encoding: ParameterEncoding = method == .get ? URLEncoding.default : JSONEncoding.default
        
        AF.request(
            url,
            method: alamofireMethod(from: method),
            parameters: finalParameters,
            encoding: encoding,
            headers: HTTPHeaders(allHeaders)
        ).responseData { [weak self] response in
            self?.handleResponse(response: response, 
                              url: url, 
                              method: method, 
                              cacheKey: "\(url.absoluteString)_\(finalParameters.description)", 
                              useCache: useCache, 
                              completion: completion)
        }
    }
    
    /// Handle API response and perform caching if needed
    /// - Parameters:
    ///   - response: The response from the API
    ///   - url: The request URL
    ///   - method: The HTTP method used
    ///   - cacheKey: Key to use for caching
    ///   - useCache: Whether to cache the response
    ///   - completion: Callback with the decoded result
    private func handleResponse<T: Decodable>(
        response: AFDataResponse<Data>,
        url: URL,
        method: HTTPMethod,
        cacheKey: String,
        useCache: Bool,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        switch response.result {
        case .success(let data):
            // Log response details
            let statusCode = response.response?.statusCode ?? 0
            let rateLimitRemaining = response.response?.allHeaderFields["X-RateLimit-Remaining"] as? String ?? "Unknown"
            let rateLimitReset = response.response?.allHeaderFields["X-RateLimit-Reset"] as? String ?? "Unknown"
            
            // Display remaining API request quota
            print("[Network] Response: \(statusCode), Rate Limit Remaining: \(rateLimitRemaining), Reset: \(rateLimitReset)")
            
            if let string = String(data: data, encoding: .utf8) {
                print("📄 Response Data: \(string.prefix(500))...")
            }
            
            if let statusCode = response.response?.statusCode {
                if statusCode >= 400 {
                    do {
                        let json = try JSON(data: data)
                        if let message = json["message"].string {
                            print("⚠️ API Error: \(message)")
                            
                            switch statusCode {
                            case 401:
                                completion(.failure(NetworkError.unauthorized))
                                return
                            case 403:
                                if message.contains("API rate limit exceeded") {
                                    completion(.failure(NetworkError.rateLimitExceeded))
                                } else {
                                    completion(.failure(NetworkError.serverError(statusCode: statusCode)))
                                }
                                return
                            default:
                                completion(.failure(NetworkError.serverError(statusCode: statusCode)))
                                return
                            }
                        }
                    } catch {
                        print("❌ Error parsing JSON error response")
                    }
                }
            }
            
            do {
                let decodedObject = try JSONDecoder().decode(T.self, from: data)
                
                // Cache data for future use
                if let response = response.response, 
                   200...299 ~= response.statusCode,
                   method == .get && useCache {
                    
                    // For GET requests, cache the response
                    self.cache.store(data, forKey: cacheKey)
                }
                
                completion(.success(decodedObject))
            } catch {
                print("❌ Decoding Error: \(error)")
                print("❌ Error data: \(String(data: data, encoding: .utf8) ?? "No data")")
                completion(.failure(NetworkError.decodingError))
            }
        case .failure(let error):
            print("❌ Network Error: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
    
    /// Convenience method for making simple network requests without parameters or headers
    /// - Parameters:
    ///   - endpoint: The API endpoint URL
    ///   - method: The HTTP method to use
    ///   - completion: Callback with the result containing the decoded response or an error
    func request<T: Decodable>(endpoint: String, method: HTTPMethod, completion: @escaping (Result<T, Error>) -> Void) {
        request(endpoint: endpoint, method: method, parameters: nil, headers: nil, completion: completion)
    }
    
    /// Convert our HTTP method enum to Alamofire's HTTP method enum
    /// - Parameter method: Our HTTP method
    /// - Returns: Equivalent Alamofire HTTP method
    private func alamofireMethod(from method: HTTPMethod) -> Alamofire.HTTPMethod {
        switch method {
        case .get:
            return .get
        case .post:
            return .post
        case .put:
            return .put
        case .delete:
            return .delete
        }
    }
    
    /// Clear all cached responses
    func clearCache() {
        cache.removeAll()
    }
    
    /// Clear cache for a specific endpoint
    /// - Parameter endpoint: The endpoint URL to clear cache for
    func clearCache(for endpoint: String) {
        // Find all keys that start with this endpoint
        let key = endpoint
        cache.remove(forKey: key)
        print("🧹 Cleared cached response for: \(endpoint)")
    }
    
    /// Remove expired items from the cache
    /// - Parameter maxAge: Maximum age in seconds for cached items
    func removeExpiredCache(maxAge: TimeInterval = 300) {
        cache.removeExpired(maxAge: maxAge)
    }
}
