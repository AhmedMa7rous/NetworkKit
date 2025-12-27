//
//  HTTPMethod.swift
//  NetworkKit
//
//  Created by Ahmed Mahrous on 26/12/2025.
//

import Foundation

/// Represents HTTP request methods
///
/// Conformance to `Sendable` ensures thread-safety in concurrent contexts.
///
/// Example:
/// ```swift
/// let method: HTTPMethod = .post
/// ```
public enum HTTPMethod: String, Sendable {
    /// GET method - Retrieve data
    case get = "GET"
    
    /// POST method - Create new resource
    case post = "POST"
    
    /// PUT method - Update/replace resource
    case put = "PUT"
    
    /// PATCH method - Partial update
    case patch = "PATCH"
    
    /// DELETE method - Remove resource
    case delete = "DELETE"
    
    /// HEAD method - Get headers only
    case head = "HEAD"
    
    /// OPTIONS method - Get allowed methods
    case options = "OPTIONS"
}
