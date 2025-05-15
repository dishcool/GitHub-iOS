//
//  AuthenticationServiceProtocol.swift
//  GitHub
//
//  Created by Dishcool on 2025/5/15.
//

import Foundation

protocol AuthenticationServiceProtocol {
    func authenticate(completion: @escaping (Result<User, Error>) -> Void)
    func authenticateWithBiometric(completion: @escaping (Result<User, Error>) -> Void)
    func logout(completion: @escaping (Result<Void, Error>) -> Void)
    func checkToken(completion: @escaping (Result<User, Error>) -> Void)
} 