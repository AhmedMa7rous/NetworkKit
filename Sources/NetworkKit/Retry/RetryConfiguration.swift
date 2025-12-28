//
//  RetryConfiguration.swift
//  NetworkKit
//
//  Created by Ahmed Mahrous on 26/12/2025.
//

import Foundation

/// Configuration for retry behavior
///
/// Defines which requests should be retried and how.
///
/// Example:
/// ```swift
/// let config = RetryConfiguration(
///     maxRetries: 3,
///     retryableStatusCodes: [408, 429, 500, 502, 503, 504],
///     retryableHTTPMethods: [.get, .delete],
///     baseDelay: 1.0,
///     maxDelay: 32.0,
///     useExponentialBackoff: true
/// )
/// ```
public struct RetryConfiguration: Sendable {
    /// Maximum number of retry attempts
    public let maxRetries: Int
    
    /// HTTP status codes that should trigger a retry
    public let retryableStatusCodes: Set<Int>
    
    /// HTTP methods that can be retried
    public let retryableHTTPMethods: Set<HTTPMethod>
    
    /// Base delay between retries (in seconds)
    public let baseDelay: TimeInterval
    
    /// Maximum delay between retries (in seconds)
    public let maxDelay: TimeInterval
    
    /// Whether to use exponential backoff
    public let useExponentialBackoff: Bool
    
    /// Default retry configuration
    ///
    /// - Max retries: 3
    /// - Retryable status codes: 408, 429, 500, 502, 503, 504
    /// - Retryable methods: GET, DELETE, HEAD
    /// - Base delay: 1 second
    /// - Max delay: 32 seconds
    /// - Exponential backoff: enabled
    public static let `default` = RetryConfiguration(
        maxRetries: 3,
        retryableStatusCodes: [408, 429, 500, 502, 503, 504],
        retryableHTTPMethods: [.get, .delete, .head],
        baseDelay: 1.0,
        maxDelay: 32.0,
        useExponentialBackoff: true
    )
    
    /// Create custom retry configuration
    ///
    /// - Parameters:
    ///   - maxRetries: Maximum number of retry attempts
    ///   - retryableStatusCodes: Status codes that trigger retry
    ///   - retryableHTTPMethods: HTTP methods that can be retried
    ///   - baseDelay: Base delay in seconds
    ///   - maxDelay: Maximum delay in seconds
    ///   - useExponentialBackoff: Whether to use exponential backoff
    public init(
        maxRetries: Int,
        retryableStatusCodes: Set<Int>,
        retryableHTTPMethods: Set<HTTPMethod>,
        baseDelay: TimeInterval,
        maxDelay: TimeInterval,
        useExponentialBackoff: Bool
    ) {
        self.maxRetries = maxRetries
        self.retryableStatusCodes = retryableStatusCodes
        self.retryableHTTPMethods = retryableHTTPMethods
        self.baseDelay = baseDelay
        self.maxDelay = maxDelay
        self.useExponentialBackoff = useExponentialBackoff
    }
}
