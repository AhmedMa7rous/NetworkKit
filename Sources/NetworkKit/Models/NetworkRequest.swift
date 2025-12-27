//
//  NetworkRequest.swift
//  NetworkKit
//
//  Created by Ahmed Mahrous on 26/12/2025.
//

import Foundation

/// Represents a network request with all necessary data
///
/// This struct is immutable and thread-safe, containing only the essential
/// data needed to execute a network request.
///
/// Use `NetworkRequestBuilder` to construct instances of this type.
///
/// Example:
/// ```swift
/// let request = NetworkRequest(
///     url: "https://api.example.com/users",
///     method: .get,
///     headers: ["Authorization": "Bearer token"],
///     body: nil,
///     timeout: 30
/// )
/// ```
public struct NetworkRequest: Sendable {
    /// The URL string for the request
    public let url: String
    
    /// HTTP method to use
    public let method: HTTPMethod
    
    /// HTTP headers to include
    public let headers: [String: String]
    
    /// Request body data (optional)
    public let body: Data?
    
    /// Request timeout interval in seconds
    public let timeout: TimeInterval
    
    /// Creates a new network request
    ///
    /// - Parameters:
    ///   - url: The URL string for the request
    ///   - method: HTTP method (default: .get)
    ///   - headers: HTTP headers (default: empty)
    ///   - body: Request body data (default: nil)
    ///   - timeout: Timeout interval (default: 30 seconds)
    public init(
        url: String,
        method: HTTPMethod = .get,
        headers: [String: String] = [:],
        body: Data? = nil,
        timeout: TimeInterval = 30
    ) {
        self.url = url
        self.method = method
        self.headers = headers
        self.body = body
        self.timeout = timeout
    }
    
    /// Unique cache key for this request
    ///
    /// Used by cache storage to identify cached responses
    public var cacheKey: String {
        url
    }
}
