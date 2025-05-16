//
//  NetworkService.swift
//  GitHub
//
//  Created by Dishcool on 2025/5/15.
//

import Foundation
import Alamofire
import SwiftyJSON

class NetworkService: NetworkServiceProtocol {
    // You can set your GitHub Personal Access Token here
    // If you don't have one, you can create it via https://github.com/settings/tokens
    private let githubToken: String? = "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"
    
    private var defaultHeaders: [String: String] {
        var headers = [
            "Accept": "application/json"
        ]
        
        // If there's an authentication token, add it to the request headers
        if let token = githubToken, !token.isEmpty {
            headers["Authorization"] = "token \(token)"
        }
        
        return headers
    }
    
    // Simple in-memory cache for caching GET request responses
    private var cache = NSCache<NSString, CacheEntry>()
    
    // Cache time-to-live (seconds)
    private let cacheTTL: TimeInterval = 300 // 5 minutes
    
    private let session: Session
    
    init(session: Session = .default) {
        self.session = session
        
        // Configure cache
        cache.countLimit = 100 // Cache at most 100 requests
    }
    
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
            let cacheKey = NSString(string: endpoint + (parameters?.description ?? ""))
            
            if let cachedResponse = cache.object(forKey: cacheKey) {
                // Check if cache is expired
                if Date().timeIntervalSince(cachedResponse.timestamp) < cacheTTL {
                    do {
                        // Try to decode from cache
                        let decodedObject = try JSONDecoder().decode(T.self, from: cachedResponse.data)
                        print("🧩 Using cached response for: \(endpoint)")
                        completion(.success(decodedObject))
                        return
                    } catch {
                        print("⚠️ Failed to decode cached response: \(error)")
                        // Cache decoding failed, continue with network request
                    }
                } else {
                    print("⏱️ Cache expired for: \(endpoint)")
                    // Cache expired, continue with network request
                }
            }
        }
        
        let allHeaders = defaultHeaders.merging(headers ?? [:]) { (_, new) in new }
        
        print("🌐 API Request: \(method.rawValue) \(endpoint)")
        print("🔑 Headers: \(allHeaders.filter { $0.key != "Authorization" })")
        if let parameters = parameters {
            print("📦 Parameters: \(parameters)")
        }
        
        let encoding: ParameterEncoding = method == .get ? URLEncoding.default : JSONEncoding.default
        
        AF.request(
            url,
            method: alamofireMethod(from: method),
            parameters: parameters,
            encoding: encoding,
            headers: HTTPHeaders(allHeaders)
        ).responseData { response in
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
                       method == .get {
                        
                        // For GET requests, cache the response
                        self.cache.setObject(CacheEntry(data: data, timestamp: Date()), forKey: NSString(string: url.absoluteString))
                        print("💾 Cached response for: \(endpoint)")
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
    }
    
    func request<T: Decodable>(endpoint: String, method: HTTPMethod, completion: @escaping (Result<T, Error>) -> Void) {
        request(endpoint: endpoint, method: method, parameters: nil, headers: nil, completion: completion)
    }
    
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
    
    // Clear all caches
    func clearCache() {
        cache.removeAllObjects()
        print("🧹 Cleared all cached responses")
    }
    
    // Clear cache for a specific endpoint
    func clearCache(for endpoint: String) {
        let cacheKey = NSString(string: endpoint)
        cache.removeObject(forKey: cacheKey)
        print("🧹 Cleared cached response for: \(endpoint)")
    }
}

/// Cache entry class for storing cached data and timestamps
class CacheEntry {
    let data: Data
    let timestamp: Date
    
    init(data: Data, timestamp: Date) {
        self.data = data
        self.timestamp = timestamp
    }
} 
