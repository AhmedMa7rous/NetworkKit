//
//  RequestInterceptor.swift
//  NetworkKit
//
//  Created by Ahmed Mahrous on 26/12/2025.
//

import Foundation

/// Protocol for intercepting and modifying network requests/responses
///
/// Interceptors can modify requests before they're sent and react to
/// responses after they're received. Common uses include adding
/// authentication, logging, and error handling.
///
/// Example:
/// ```swift
/// final class AuthInterceptor: RequestInterceptor {
///     func adapt(_ request: URLRequest) async throws -> URLRequest {
///         var request = request
///         request.setValue("Bearer token", forHTTPHeaderField: "Authorization")
///         return request
///     }
/// }
/// ```
public protocol RequestInterceptor: Sendable {
    /// Adapt/modify a request before it's sent
    ///
    /// Use this to add headers, modify URL, etc.
    ///
    /// - Parameter request: The original URLRequest
    /// - Returns: Modified URLRequest
    /// - Throws: Error if adaptation fails
    func adapt(_ request: URLRequest) async throws -> URLRequest
    
    /// Called after receiving a response
    ///
    /// Use this for logging, token refresh, etc.
    ///
    /// - Parameters:
    ///   - result: The result of the network request
    ///   - request: The original URLRequest
    func didReceive(_ result: Result<NetworkResponse, Error>, for request: URLRequest) async
}

/// Default implementation for didReceive (optional)
public extension RequestInterceptor {
    func didReceive(_ result: Result<NetworkResponse, Error>, for request: URLRequest) async {
        // Default empty implementation
    }
}
