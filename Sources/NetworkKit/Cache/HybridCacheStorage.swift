//
//  HybridCacheStorage.swift
//  NetworkKit
//
//  Created by Ahmed Mahrous on 27/12/2025.
//

import Foundation

/// Hybrid cache using both memory and disk
///
/// Combines memory and disk caching for optimal performance.
/// Checks memory first (fast), falls back to disk (persistent).
///
/// Example:
/// ```swift
/// let cache = HybridCacheStorage()
/// let client = NetworkClient(
///     cacheStorage: cache,
///     cachePolicy: .hybrid(ttl: 600)
/// )
/// ```
public final class HybridCacheStorage: CacheStorage {
    private let memoryStorage: any CacheStorage
    private let diskStorage: any CacheStorage
    
    /// Initialize hybrid cache
    ///
    /// - Parameters:
    ///   - memoryStorage: Memory cache to use (default: MemoryCacheStorage)
    ///   - diskStorage: Disk cache to use (default: DiskCacheStorage)
    public init(
        memoryStorage: any CacheStorage = MemoryCacheStorage(),
        diskStorage: any CacheStorage = DiskCacheStorage()
    ) {
        self.memoryStorage = memoryStorage
        self.diskStorage = diskStorage
    }
    
    public func store(_ data: Data, forKey key: String, ttl: TimeInterval) {
        memoryStorage.store(data, forKey: key, ttl: ttl)
        diskStorage.store(data, forKey: key, ttl: ttl)
    }
    
    public func retrieve(forKey key: String) -> Data? {
        // Try memory first (fast)
        if let data = memoryStorage.retrieve(forKey: key) {
            return data
        }
        
        // Fallback to disk (slower but persistent)
        if let data = diskStorage.retrieve(forKey: key) {
            // Promote to memory for faster future access
            memoryStorage.store(data, forKey: key, ttl: 300) // 5 min default
            return data
        }
        
        return nil
    }
    
    public func remove(forKey key: String) {
        memoryStorage.remove(forKey: key)
        diskStorage.remove(forKey: key)
    }
    
    public func clear() {
        memoryStorage.clear()
        diskStorage.clear()
    }
}
