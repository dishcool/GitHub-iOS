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

enum NetworkError: Error {
    case invalidEndpoint
    case invalidResponse
    case decodingError
    case serverError(statusCode: Int)
    case unknown
    case invalidURL
    case noData
    case unauthorized
    case rateLimitExceeded
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