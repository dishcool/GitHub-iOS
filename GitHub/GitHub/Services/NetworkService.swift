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
    /// Default headers to include in all requests
    private var defaultHeaders: [String: String] {
        var headers = [
            AppConstants.Network.Headers.accept: AppConstants.Network.HeaderValues.jsonContent
        ]
        
        // Get token from KeychainService instead of hardcoded value
        if let token = KeychainService.shared.retrieveToken(), !token.isEmpty {
            headers[AppConstants.Network.Headers.authorization] = String(format: AppConstants.Network.HeaderValues.tokenFormat, token)
        }
        
        return headers
    }
    
    // Use our new cache implementation
    private let cache: NetworkCacheProtocol
    
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
                if Date().timeIntervalSince(cachedEntry.timestamp) < AppConstants.Network.defaultCacheTTL {
                    do {
                        // Try to decode from cache
                        let decodedObject = try JSONDecoder().decode(T.self, from: cachedEntry.data)
                        print(String(format: AppStrings.Cache.usingCachedResponse, endpoint))
                        completion(.success(decodedObject))
                        return
                    } catch {
                        print(String(format: AppStrings.Cache.failedDecoding, error.localizedDescription))
                        // Cache decoding failed, continue with network request
                    }
                } else {
                    print(String(format: AppStrings.Cache.cacheExpired, endpoint))
                    // Expired cache entry should be removed
                    cache.remove(forKey: cacheKey)
                }
            }
        }
        
        let allHeaders = defaultHeaders.merging(headers ?? [:]) { (_, new) in new }
        
        print(String(format: AppStrings.Network.requestLog, method.rawValue, endpoint))
        print(String(format: AppStrings.Network.headersLog, allHeaders.filter { $0.key != AppConstants.Network.Headers.authorization }))
        if let parameters = parameters {
            print(String(format: AppStrings.Network.parametersLog, parameters))
        }
        
        // Determine if we're making an authenticated request
        let isAuthenticated = allHeaders[AppConstants.Network.Headers.authorization] != nil
        
        // For unauthenticated requests to GitHub API, add client_id and client_secret as parameters
        var finalParameters = parameters ?? [:]
        if !isAuthenticated && endpoint.contains(AppConstants.GitHub.apiBaseUrl) {
            // Only add client credentials for GitHub API requests
            var urlComponents = URLComponents(string: endpoint)
            
            // Add client_id and client_secret to URL for GET requests
            if method == .get {
                var queryItems = urlComponents?.queryItems ?? []
                queryItems.append(URLQueryItem(name: AppConstants.Network.QueryParams.clientID, value: AppConstants.GitHub.clientID))
                queryItems.append(URLQueryItem(name: AppConstants.Network.QueryParams.clientSecret, value: AppConstants.GitHub.clientSecret))
                urlComponents?.queryItems = queryItems
                
                if let newURL = urlComponents?.url {
                    print(AppStrings.Network.clientCredentialsLog)
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
                finalParameters[AppConstants.Network.QueryParams.clientID] = AppConstants.GitHub.clientID
                finalParameters[AppConstants.Network.QueryParams.clientSecret] = AppConstants.GitHub.clientSecret
                print(AppStrings.Network.clientCredentialsLog)
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
            let rateLimitRemaining = response.response?.allHeaderFields[AppConstants.Network.Headers.rateLimitRemaining] as? String ?? "Unknown"
            let rateLimitReset = response.response?.allHeaderFields[AppConstants.Network.Headers.rateLimitReset] as? String ?? "Unknown"
            
            // Display remaining API request quota
            print(String(format: AppStrings.Network.responseLog, statusCode, rateLimitRemaining, rateLimitReset))
            
            if let string = String(data: data, encoding: .utf8) {
                print(String(format: AppStrings.Network.responseDataLog, String(string.prefix(500))))
            }
            
            if let statusCode = response.response?.statusCode {
                if statusCode >= 400 {
                    do {
                        let json = try JSON(data: data)
                        if let message = json["message"].string {
                            print(String(format: AppStrings.Network.apiErrorLog, message))
                            
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
                        print(AppStrings.Network.errorParsingJsonLog)
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
                    print(String(format: AppStrings.Cache.storedInCache, cacheKey))
                }
                
                completion(.success(decodedObject))
            } catch {
                print(String(format: AppStrings.Network.decodingErrorLog, error.localizedDescription))
                print(String(format: AppStrings.Network.errorDataLog, String(data: data, encoding: .utf8) ?? "No data"))
                completion(.failure(NetworkError.decodingError))
            }
        case .failure(let error):
            print(String(format: AppStrings.Network.networkErrorLog, error.localizedDescription))
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
        print(String(format: AppStrings.Cache.removedFromCache, endpoint))
    }
    
    /// Remove expired items from the cache
    /// - Parameter maxAge: Maximum age in seconds for cached items
    func removeExpiredCache(maxAge: TimeInterval = AppConstants.Network.defaultCacheTTL) {
        let count = cache.removeExpired(maxAge: maxAge)
        print(String(format: AppStrings.Cache.removedExpiredEntries, count))
    }
}
