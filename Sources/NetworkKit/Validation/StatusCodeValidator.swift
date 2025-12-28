//
//  StatusCodeValidator.swift
//  NetworkKit
//
//  Created by Ahmed Mahrous on 27/12/2025.
//

import Foundation

/// Validates HTTP status codes
///
/// Default validator that checks if status code is in acceptable range.
///
/// Example:
/// ```swift
/// // Accept only 2xx status codes
/// let validator = StatusCodeValidator(acceptableStatusCodes: 200..<300)
///
/// // Accept 2xx and 3xx
/// let validator = StatusCodeValidator(acceptableStatusCodes: 200..<400)
/// ```
public struct StatusCodeValidator: ResponseValidator {
    private let acceptableStatusCodes: Range<Int>
    
    /// Initialize with acceptable status code range
    ///
    /// - Parameter acceptableStatusCodes: Range of acceptable status codes (default: 200..<300)
    public init(acceptableStatusCodes: Range<Int> = 200..<300) {
        self.acceptableStatusCodes = acceptableStatusCodes
    }
    
    public func validate(_ response: URLResponse, data: Data?) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown("Invalid response type")
        }
        
        guard acceptableStatusCodes.contains(httpResponse.statusCode) else {
            throw mapStatusCodeToError(httpResponse.statusCode)
        }
    }
    
    private func mapStatusCodeToError(_ statusCode: Int) -> NetworkError {
        switch statusCode {
        case 401:
            return .unauthorized
        case 403:
            return .forbidden
        case 404:
            return .notFound
        case 500...599:
            return .serverError
        default:
            return .httpError(statusCode: statusCode)
        }
    }
}
