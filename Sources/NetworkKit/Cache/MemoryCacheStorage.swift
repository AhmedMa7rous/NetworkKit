//
//  MemoryCacheStorage.swift
//  NetworkKit
//
//  Created by Ahmed Mahrous on 27/12/2025.
//

import Foundation

/// In-memory cache storage implementation
///
/// Uses NSCache for automatic memory management.
/// Cache is cleared when memory pressure occurs.
///
/// Example:
/// ```swift
/// let cache = MemoryCacheStorage(
///     countLimit: 100,
///     costLimit: 50 * 1024 * 1024 // 50 MB
/// )
/// ```
public final class MemoryCacheStorage: CacheStorage, @unchecked Sendable {
    private let cache = NSCache<NSString, CachedItem>()
    
    /// Initialize memory cache with limits
    ///
    /// - Parameters:
    ///   - countLimit: Maximum number of items (default: 100)
    ///   - costLimit: Maximum total cost in bytes (default: 50MB)
    public init(countLimit: Int = 100, costLimit: Int = 50 * 1024 * 1024) {
        cache.countLimit = countLimit
        cache.totalCostLimit = costLimit
    }
    
    public func store(_ data: Data, forKey key: String, ttl: TimeInterval) {
        let item = CachedItem(data: data, expirationDate: Date().addingTimeInterval(ttl))
        cache.setObject(item, forKey: key as NSString, cost: data.count)
    }
    
    public func retrieve(forKey key: String) -> Data? {
        guard let item = cache.object(forKey: key as NSString),
              !item.isExpired else {
            return nil
        }
        return item.data
    }
    
    public func remove(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
    }
    
    public func clear() {
        cache.removeAllObjects()
    }
}

private final class CachedItem: NSObject, @unchecked Sendable {
    let data: Data
    let expirationDate: Date
    
    init(data: Data, expirationDate: Date) {
        self.data = data
        self.expirationDate = expirationDate
    }
    
    var isExpired: Bool {
        Date() > expirationDate
    }
}
