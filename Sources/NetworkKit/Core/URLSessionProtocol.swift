//
//  URLSessionProtocol.swift
//  NetworkKit
//
//  Created by Ahmed Mahrous on 27/12/2025.
//

import Foundation

/// Protocol abstraction for URLSession
///
/// Allows mocking URLSession for testing purposes.
///
/// Example:
/// ```swift
/// // Production
/// let client = NetworkClient(session: URLSession.shared)
///
/// // Testing
/// let mockSession = MockURLSession()
/// let client = NetworkClient(session: mockSession)
/// ```
public protocol URLSessionProtocol: Sendable {
    /// Perform data request
    ///
    /// - Parameter request: URLRequest to execute
    /// - Returns: Tuple of data and response
    /// - Throws: URLError on failure
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

/// URLSession conforms to URLSessionProtocol
extension URLSession: URLSessionProtocol {}
