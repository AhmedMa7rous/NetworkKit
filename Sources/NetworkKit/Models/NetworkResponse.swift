//
//  NetworkResponse.swift
//  NetworkKit
//
//  Created by Ahmed Mahrous on 27/12/2025.
//

import Foundation

/// Represents a network response with data and metadata
///
/// Contains the response data, HTTP status code, and headers.
///
/// Example:
/// ```swift
/// let response = NetworkResponse(
///     data: responseData,
///     statusCode: 200,
///     headers: ["Content-Type": "application/json"]
/// )
/// ```
public struct NetworkResponse: Sendable {
    /// Response body data
    public let data: Data
    
    /// HTTP status code
    public let statusCode: Int
    
    /// HTTP response headers
    public let headers: [String: String]
    
    /// Creates a new network response
    ///
    /// - Parameters:
    ///   - data: Response body data
    ///   - statusCode: HTTP status code
    ///   - headers: HTTP response headers
    public init(data: Data, statusCode: Int, headers: [String: String]) {
        self.data = data
        self.statusCode = statusCode
        self.headers = headers
    }
}
