//
//  NetworkServiceProtocol.swift
//  GitHub
//
//  Created by Dishcool on 2025/5/15.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum NetworkError: Error, Equatable {
    case invalidEndpoint
    case invalidResponse
    case decodingError
    case serverError(statusCode: Int)
    case unknown
    case invalidURL
    case noData
    case unauthorized
    case rateLimitExceeded
    
    // 实现 Equatable 协议所需的方法
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidEndpoint, .invalidEndpoint),
             (.invalidResponse, .invalidResponse),
             (.decodingError, .decodingError),
             (.unknown, .unknown),
             (.invalidURL, .invalidURL),
             (.noData, .noData),
             (.unauthorized, .unauthorized),
             (.rateLimitExceeded, .rateLimitExceeded):
            return true
        case (.serverError(let lhsCode), .serverError(let rhsCode)):
            return lhsCode == rhsCode
        default:
            return false
        }
    }
}

protocol NetworkServiceProtocol {
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        parameters: [String: Any]?,
        headers: [String: String]?,
        useCache: Bool,
        completion: @escaping (Result<T, Error>) -> Void
    )
    
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        completion: @escaping (Result<T, Error>) -> Void
    )
    
    func clearCache()
    func clearCache(for endpoint: String)
} 