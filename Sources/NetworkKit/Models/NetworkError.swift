//
//  NetworkError.swift
//  NetworkKit
//
//  Created by Ahmed Mahrous on 26/12/2025.
//

import Foundation

/// Represents all possible network-related errors
///
/// This enum provides comprehensive error handling for network operations,
/// making it easy to identify and handle specific failure cases.
///
/// Example:
/// ```swift
/// do {
///     let data = try await client.request(request)
/// } catch let error as NetworkError {
///     switch error {
///     case .unauthorized:
///         // Handle authentication error
///     case .noInternetConnection:
///         // Handle connectivity error
///     default:
///         // Handle other errors
///     }
/// }
/// ```
public enum NetworkError: Error, Sendable, Equatable {
    /// The provided URL is invalid or malformed
    case invalidURL
    
    /// No data was received from the server
    case noData
    
    /// Failed to decode the response data
    /// - Parameter message: Description of the decoding failure
    case decodingFailed(String)
    
    /// Failed to encode the request data
    /// - Parameter message: Description of the encoding failure
    case encodingFailed(String)
    
    /// HTTP error with specific status code
    /// - Parameter statusCode: The HTTP status code received
    case httpError(statusCode: Int)
    
    /// 401 Unauthorized - Authentication required
    case unauthorized
    
    /// 403 Forbidden - Access denied
    case forbidden
    
    /// 404 Not Found - Resource not found
    case notFound
    
    /// 5xx Server Error - Internal server error
    case serverError
    
    /// Request timed out
    case timeout
    
    /// No internet connection available
    case noInternetConnection
    
    /// Request was cancelled
    case cancelled
    
    /// Unknown error with description
    /// - Parameter message: Unknown error message
    case unknown(String)
    
    /// Human-readable error description
    public var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "❌:Invalid URL provided"
        case .noData:
            return "⚠️: No data received from server"
        case .decodingFailed(let messege):
            return "❌ Failed to decode response: \(messege)"
        case .encodingFailed(let messege):
            return "❌ Failed to encode request: \(messege)"
        case .httpError(let statusCode):
            return "❌ HTTP error with status code: \(statusCode)"
        case .unauthorized:
            return "⚠️: Unauthorized - Authentication required"
        case .forbidden:
            return "Forbidden - Access denied"
        case .notFound:
            return "⚠️: Resource not found"
        case .serverError:
            return "❌: Internal server error"
        case .timeout:
            return "⏳: Request timed out"
        case .noInternetConnection:
            return "⚠️: No internet connection available"
        case .cancelled:
            return "⚠️: Request was cancelled"
        case .unknown(let messege):
            return "Unknown error: \(messege)"
        }
    }
}
