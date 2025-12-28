//
//  ResponseValidator.swift
//  NetworkKit
//
//  Created by Ahmed Mahrous on 27/12/2025.
//

import Foundation

/// Protocol for validating network responses
///
/// Implement this protocol to create custom response validation logic.
///
/// Example:
/// ```swift
/// struct CustomValidator: ResponseValidator {
///     func validate(_ response: URLResponse, data: Data?) throws {
///         guard let httpResponse = response as? HTTPURLResponse else {
///             throw NetworkError.custom("Invalid response")
///         }
///
///         guard httpResponse.statusCode == 200 else {
///             throw NetworkError.httpError(statusCode: httpResponse.statusCode)
///         }
///     }
/// }
/// ```
public protocol ResponseValidator: Sendable {
    /// Validate a network response
    ///
    /// - Parameters:
    ///   - response: The URLResponse to validate
    ///   - data: Optional response data
    /// - Throws: NetworkError if validation fails
    func validate(_ response: URLResponse, data: Data?) throws
}
