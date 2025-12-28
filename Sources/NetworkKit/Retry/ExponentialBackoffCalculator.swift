//
//  ExponentialBackoffCalculator.swift
//  NetworkKit
//
//  Created by Ahmed Mahrous on 27/12/2025.
//

import Foundation

/// Calculates exponential backoff delays
///
/// Implements exponential backoff algorithm with configurable base delay
/// and maximum delay cap.
///
/// Formula: min(baseDelay * 2^(attempt - 1), maxDelay)
///
/// Example:
/// ```swift
/// let calculator = ExponentialBackoffCalculator(
///     baseDelay: 1.0,
///     maxDelay: 32.0
/// )
///
/// let delay1 = calculator.delay(for: 1) // 1.0 second
/// let delay2 = calculator.delay(for: 2) // 2.0 seconds
/// let delay3 = calculator.delay(for: 3) // 4.0 seconds
/// let delay4 = calculator.delay(for: 4) // 8.0 seconds
/// ```
public struct ExponentialBackoffCalculator: Sendable {
    private let baseDelay: TimeInterval
    private let maxDelay: TimeInterval
    
    /// Initialize backoff calculator
    ///
    /// - Parameters:
    ///   - baseDelay: Base delay in seconds
    ///   - maxDelay: Maximum delay cap in seconds
    public init(baseDelay: TimeInterval, maxDelay: TimeInterval) {
        self.baseDelay = baseDelay
        self.maxDelay = maxDelay
    }
    
    /// Calculate delay for given attempt number
    ///
    /// - Parameter attempt: Attempt number (1-based)
    /// - Returns: Calculated delay in seconds
    public func delay(for attempt: Int) -> TimeInterval {
        let exponentialDelay = baseDelay * pow(2.0, Double(attempt - 1))
        return min(exponentialDelay, maxDelay)
    }
}
