//
//  DiskCacheStorage.swift
//  NetworkKit
//
//  Created by Ahmed Mahrous on 27/12/2025.
//

import Foundation

/// Disk-based cache storage implementation
///
/// Persists cached data to disk in the Caches directory.
/// Cache survives app restarts but can be cleared by the system.
///
/// Example:
/// ```swift
/// let cache = DiskCacheStorage(directoryName: "MyAppCache")
/// ```
public final class DiskCacheStorage: CacheStorage, @unchecked Sendable {
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    private let queue = DispatchQueue(label: "com.networkkit.diskcache", attributes: .concurrent)
    
    /// Initialize disk cache with directory name
    ///
    /// - Parameter directoryName: Name of cache directory (default: "NetworkKit")
    public init(directoryName: String = "NetworkKit") {
        let cacheDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        cacheDirectory = cacheDir.appendingPathComponent(directoryName, isDirectory: true)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    public func store(_ data: Data, forKey key: String, ttl: TimeInterval) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            let fileURL = self.fileURL(forKey: key)
            let wrapper = DiskCacheWrapper(data: data, expirationDate: Date().addingTimeInterval(ttl))
            
            do {
                let encoded = try JSONEncoder().encode(wrapper)
                try encoded.write(to: fileURL, options: .atomic)
            } catch {
                print("Failed to write to disk: \(error)")
            }
        }
    }
    
    public func retrieve(forKey key: String) -> Data? {
        let fileURL = fileURL(forKey: key)
        
        guard let data = try? Data(contentsOf: fileURL),
              let wrapper = try? JSONDecoder().decode(DiskCacheWrapper.self, from: data),
              !wrapper.isExpired else {
            return nil
        }
        
        return wrapper.data
    }
    
    public func remove(forKey key: String) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            let fileURL = self.fileURL(forKey: key)
            try? self.fileManager.removeItem(at: fileURL)
        }
    }
    
    public func clear() {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            try? self.fileManager.removeItem(at: self.cacheDirectory)
            try? self.fileManager.createDirectory(at: self.cacheDirectory, withIntermediateDirectories: true)
        }
    }
    
    private func fileURL(forKey key: String) -> URL {
        let filename = key.sha256
        return cacheDirectory.appendingPathComponent(filename)
    }
}

private struct DiskCacheWrapper: Codable {
    let data: Data
    let expirationDate: Date
    
    var isExpired: Bool {
        Date() > expirationDate
    }
}

private extension String {
    var sha256: String {
        guard let data = self.data(using: .utf8) else { return self }
        return data.base64EncodedString()
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "=", with: "")
    }
}
