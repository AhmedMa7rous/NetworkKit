//
//  RequestRetrier.swift
//  NetworkKit
//
//  Created by Ahmed Mahrous on 27/12/2025.
//

import Foundation

/// Protocol for implementing retry logic
///
/// Determines whether a failed request should be retried and
/// calculates appropriate delays between retry attempts.
///
/// Example:
/// ```swift
/// final class CustomRetryPolicy: RequestRetrier {
///     func shouldRetry(request: NetworkRequest, error: Error, attemptCount: Int) -> Bool {
///         return attemptCount < 3 && isRetryableError(error)
///     }
///
///     func delayBeforeRetry(attemptCount: Int) async {
///         try? await Task.sleep(nanoseconds: UInt64(attemptCount) * 1_000_000_000)
///     }
/// }
/// ```
public protocol RequestRetrier: Sendable {
    /// Determine if request should be retried
    ///
    /// - Parameters:
    ///   - request: The failed request
    ///   - error: The error that occurred
    ///   - attemptCount: Number of attempts so far (1-based)
    /// - Returns: true if request should be retried
    func shouldRetry(request: NetworkRequest, error: Error, attemptCount: Int) -> Bool
    
    /// Calculate delay before next retry attempt
    ///
    /// - Parameter attemptCount: Number of attempts so far (1-based)
    func delayBeforeRetry(attemptCount: Int) async
}
