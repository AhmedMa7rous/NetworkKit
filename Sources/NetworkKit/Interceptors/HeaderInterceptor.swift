//
//  HeaderInterceptor.swift
//  NetworkKit
//
//  Created by Ahmed Mahrous on 27/12/2025.
//

import Foundation

/// Adds custom headers to requests
///
/// Useful for adding common headers like API keys, user agents, etc.
///
/// Example:
/// ```swift
/// let headerInterceptor = HeaderInterceptor(headers: [
///     "X-API-Key": "your-api-key",
///     "User-Agent": "MyApp/1.0",
///     "Accept": "application/json"
/// ])
///
/// let client = NetworkClient(
///     interceptors: [headerInterceptor]
/// )
/// ```
public final class HeaderInterceptor: RequestInterceptor {
    private let headers: [String: String]
    
    /// Initialize with headers to add
    ///
    /// - Parameter headers: Dictionary of headers to add to all requests
    public init(headers: [String: String]) {
        self.headers = headers
    }
    
    public func adapt(_ request: URLRequest) async throws -> URLRequest {
        var adaptedRequest = request
        
        for (key, value) in headers {
            adaptedRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        return adaptedRequest
    }
}
