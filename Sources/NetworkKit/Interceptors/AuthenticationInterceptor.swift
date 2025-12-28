//
//  AuthenticationInterceptor.swift
//  NetworkKit
//
//  Created by Ahmed Mahrous on 26/12/2025.
//

import Foundation

/// Adds authentication to requests
///
/// Automatically adds authentication headers to requests.
///
/// Example:
/// ```swift
/// let authInterceptor = AuthenticationInterceptor {
///     return await AuthManager.shared.getToken()
/// }
///
/// let client = NetworkClient(
///     interceptors: [authInterceptor]
/// )
/// ```
public final class AuthenticationInterceptor: RequestInterceptor, @unchecked Sendable {
    private let tokenProvider: @Sendable () async throws -> String?
    
    /// Initialize authentication interceptor
    ///
    /// - Parameter tokenProvider: Async closure that provides auth token
    ///
    /// Example:
    /// ```swift
    /// AuthenticationInterceptor {
    ///     return UserDefaults.standard.string(forKey: "authToken")
    /// }
    /// ```
    public init(tokenProvider: @escaping @Sendable () async throws -> String?) {
        self.tokenProvider = tokenProvider
    }
    
    public func adapt(_ request: URLRequest) async throws -> URLRequest {
        var adaptedRequest = request
        
        if let token = try await tokenProvider() {
            adaptedRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return adaptedRequest
    }
}
