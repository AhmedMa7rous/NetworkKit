//
//  NetworkCachePolicy.swift
//  NetworkKit
//
//  Created by Ahmed Mahrous on 27/12/2025.
//

import Foundation

/// Cache policy for network responses
///
/// Defines where and how long responses should be cached.
///
/// Example:
/// ```swift
/// let client = NetworkClient(
///     cacheStorage: HybridCacheStorage(),
///     cachePolicy: .hybrid(ttl: 300) // Cache for 5 minutes
/// )
/// ```
public enum NetworkCachePolicy: Sendable {
    /// No caching
    case never
    
    /// Cache in memory only
    /// - Parameter ttl: Time-to-live in seconds
    case memory(ttl: TimeInterval)
    
    /// Cache on disk only
    /// - Parameter ttl: Time-to-live in seconds
    case disk(ttl: TimeInterval)
    
    /// Cache in both memory and disk
    /// - Parameter ttl: Time-to-live in seconds
    case hybrid(ttl: TimeInterval)
    
    /// Time-to-live for cached data
    public var timeToLive: TimeInterval {
        switch self {
        case .never:
            return 0
        case .memory(let ttl), .disk(let ttl), .hybrid(let ttl):
            return ttl
        }
    }
}
