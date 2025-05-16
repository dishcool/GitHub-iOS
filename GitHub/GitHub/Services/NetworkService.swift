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
    // 你可以在这里设置你的GitHub Personal Access Token
    // 如果没有，可以通过 https://github.com/settings/tokens 创建一个
    private let githubToken: String? = "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"
    
    private var defaultHeaders: [String: String] {
        var headers = [
            "Accept": "application/json"
        ]
        
        // 如果有认证令牌，添加到请求头
        if let token = githubToken, !token.isEmpty {
            headers["Authorization"] = "token \(token)"
        }
        
        return headers
    }
    
    // 简单的内存缓存，用于缓存GET请求的响应
    private var cache = NSCache<NSString, CacheEntry>()
    
    // 缓存有效期（秒）
    private let cacheTTL: TimeInterval = 300 // 5分钟
    
    private let session: Session
    
    init(session: Session = .default) {
        self.session = session
        
        // 配置缓存
        cache.countLimit = 100 // 最多缓存100个请求
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
        
        // 对于GET请求，尝试从缓存获取
        if method == .get && useCache {
            let cacheKey = NSString(string: endpoint + (parameters?.description ?? ""))
            
            if let cachedResponse = cache.object(forKey: cacheKey) {
                // 检查缓存是否过期
                if Date().timeIntervalSince(cachedResponse.timestamp) < cacheTTL {
                    do {
                        // 尝试从缓存解码
                        let decodedObject = try JSONDecoder().decode(T.self, from: cachedResponse.data)
                        print("🧩 Using cached response for: \(endpoint)")
                        completion(.success(decodedObject))
                        return
                    } catch {
                        print("⚠️ Failed to decode cached response: \(error)")
                        // 缓存解码失败，继续请求网络
                    }
                } else {
                    print("⏱️ Cache expired for: \(endpoint)")
                    // 缓存过期，继续请求网络
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
                // 显示剩余的API请求配额
                if let remainingHeader = response.response?.headers.value(for: "X-RateLimit-Remaining"),
                   let limitHeader = response.response?.headers.value(for: "X-RateLimit-Limit") {
                    print("📊 Rate Limit: \(remainingHeader)/\(limitHeader) requests remaining")
                }
                
                print("📥 Response Status Code: \(response.response?.statusCode ?? 0)")
                
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
                    
                    // 对于GET请求，缓存响应
                    if method == .get && useCache {
                        let cacheKey = NSString(string: endpoint + (parameters?.description ?? ""))
                        let entry = CacheEntry(data: data, timestamp: Date())
                        self.cache.setObject(entry, forKey: cacheKey)
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
    
    // 清除所有缓存
    func clearCache() {
        cache.removeAllObjects()
        print("🧹 Cleared all cached responses")
    }
    
    // 清除特定端点的缓存
    func clearCache(for endpoint: String) {
        let cacheKey = NSString(string: endpoint)
        cache.removeObject(forKey: cacheKey)
        print("🧹 Cleared cached response for: \(endpoint)")
    }
}

/// 缓存条目类，用于保存缓存的数据和时间戳
class CacheEntry {
    let data: Data
    let timestamp: Date
    
    init(data: Data, timestamp: Date) {
        self.data = data
        self.timestamp = timestamp
    }
} 
