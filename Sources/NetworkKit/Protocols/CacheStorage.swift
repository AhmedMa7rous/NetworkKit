//
//  CacheStorage.swift
//  NetworkKit
//
//  Created by Ahmed Mahrous on 27/12/2025.
//

import Foundation

/// Protocol for cache storage implementations
///
/// Defines the contract for storing and retrieving cached network responses.
/// Implementations can use memory, disk, or hybrid storage strategies.
///
/// Example:
/// ```swift
/// let cache: CacheStorage = MemoryCacheStorage()
/// cache.store(data, forKey: "users-list", ttl: 300)
///
/// if let cachedData = cache.retrieve(forKey: "users-list") {
///     // Use cached data
/// }
/// ```
public protocol CacheStorage: Sendable {
    /// Store data in cache
    ///
    /// - Parameters:
    ///   - data: Data to cache
    ///   - key: Unique key for this data
    ///   - ttl: Time-to-live in seconds
    func store(_ data: Data, forKey key: String, ttl: TimeInterval)
    
    /// Retrieve data from cache
    ///
    /// Returns nil if data is not found or has expired.
    ///
    /// - Parameter key: Unique key for the data
    /// - Returns: Cached data if available and not expired
    func retrieve(forKey key: String) -> Data?
    
    /// Remove specific data from cache
    ///
    /// - Parameter key: Unique key for the data to remove
    func remove(forKey key: String)
    
    /// Clear all cached data
    func clear()
}
