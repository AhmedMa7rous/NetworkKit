//
//  DefaultRetryPolicy.swift
//  NetworkKit
//
//  Created by Ahmed Mahrous on 27/12/2025.
//

import Foundation

/// Default retry policy implementation
///
/// Determines whether failed requests should be retried based on
/// error type, HTTP method, status code, and attempt count.
///
/// Example:
/// ```swift
/// let retryPolicy = DefaultRetryPolicy(
///     configuration: .default
/// )
///
/// let client = NetworkClient(
///     retrier: retryPolicy
/// )
/// ```
public final class DefaultRetryPolicy: RequestRetrier {
    private let configuration: RetryConfiguration
    private let backoffCalculator: ExponentialBackoffCalculator
    
    /// Initialize with configuration
    ///
    /// - Parameter configuration: Retry configuration (default: .default)
    public init(configuration: RetryConfiguration = .default) {
        self.configuration = configuration
        self.backoffCalculator = ExponentialBackoffCalculator(
            baseDelay: configuration.baseDelay,
            maxDelay: configuration.maxDelay
        )
    }
    
    public func shouldRetry(request: NetworkRequest, error: any Error, attemptCount: Int) -> Bool {
        // Check max retries
        guard attemptCount < configuration.maxRetries else {
            return false
        }
        
        // Check if method is retryable
        guard configuration.retryableHTTPMethods.contains(request.method) else {
            return false
        }
        
        return isRetryableError(error)
    }
    
    public func delayBeforeRetry(attemptCount: Int) async {
        let delay = configuration.useExponentialBackoff
            ? backoffCalculator.delay(for: attemptCount)
            : configuration.baseDelay
        
        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
    }
    
    private func isRetryableError(_ error: any Error) -> Bool {
        // Check NetworkError
        if let networkError = error as? NetworkError {
            switch networkError {
            case .httpError(let statusCode):
                return configuration.retryableStatusCodes.contains(statusCode)
            case .timeout, .serverError, .noInternetConnection:
                return true
            default:
                return false
            }
        }
        
        // Check URLError
        if let urlError = error as? URLError {
            switch urlError.code {
            case .timedOut, .networkConnectionLost, .notConnectedToInternet, .cannotConnectToHost:
                return true
            default:
                return false
            }
        }
        
        return false
    }
}
