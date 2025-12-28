//
//  HTTPClient.swift
//  NetworkKit
//
//  Created by Ahmed Mahrous on 27/12/2025.
//

import Foundation

/// Low-level HTTP client
///
/// Responsible only for executing HTTP requests and validating responses.
/// Follows Single Responsibility Principle.
final class HTTPClient: @unchecked Sendable {
    private let session: any URLSessionProtocol
    private let validator: any ResponseValidator
    
    /// Initialize HTTP client
    ///
    /// - Parameters:
    ///   - session: URLSession instance (default: URLSession.shared)
    ///   - validator: Response validator (default: StatusCodeValidator)
    init(
        session: any URLSessionProtocol = URLSession.shared,
        validator: any ResponseValidator = StatusCodeValidator()
    ) {
        self.session = session
        self.validator = validator
    }
    
    /// Execute HTTP request
    ///
    /// - Parameter request: URLRequest to execute
    /// - Returns: NetworkResponse with data and metadata
    /// - Throws: NetworkError on failure
    func execute(_ request: URLRequest) async throws -> NetworkResponse {
        let (data, response) = try await session.data(for: request)
        
        try validator.validate(response, data: data)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown("Invalid response type")
        }
        
        let headers = httpResponse.allHeaderFields.reduce(into: [String: String]()) { result, pair in
            if let key = pair.key as? String, let value = pair.value as? String {
                result[key] = value
            }
        }
        
        return NetworkResponse(
            data: data,
            statusCode: httpResponse.statusCode,
            headers: headers
        )
    }
}
