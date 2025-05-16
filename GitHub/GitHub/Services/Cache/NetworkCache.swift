//
//  NetworkCache.swift
//  GitHub
//
//  Created by Dishcool on 2025/5/17.
//

import Foundation

/// Entry object for the network cache
class CacheEntry {
    /// The cached data
    let data: Data
    
    /// Timestamp when the entry was cached
    let timestamp: Date
    
    /// Initialize a new cache entry
    /// - Parameters:
    ///   - data: The data to cache
    ///   - timestamp: The time when the data was cached (defaults to current time)
    init(data: Data, timestamp: Date = Date()) {
        self.data = data
        self.timestamp = timestamp
    }
}

/// Protocol defining the operations of a network cache
protocol NetworkCacheProtocol {
    /// Check if the cache contains an entry for the given key
    /// - Parameter key: The cache key
    /// - Returns: True if the cache contains the key
    func contains(key: String) -> Bool
    
    /// Store data in the cache
    /// - Parameters:
    ///   - data: The data to cache
    ///   - key: The cache key
    func store(_ data: Data, forKey key: String)
    
    /// Retrieve data from the cache
    /// - Parameter key: The cache key
    /// - Returns: The cached entry, or nil if not found or expired
    func retrieve(forKey key: String) -> CacheEntry?
    
    /// Remove a specific entry from the cache
    /// - Parameter key: The cache key to remove
    func remove(forKey key: String)
    
    /// Remove all entries from the cache
    func removeAll()
    
    /// Remove expired entries from the cache
    /// - Parameter maxAge: Maximum age in seconds for entries to remain valid
    /// - Returns: Number of expired entries removed
    @discardableResult
    func removeExpired(maxAge: TimeInterval) -> Int
}

/// In-memory implementation of the network cache
class InMemoryNetworkCache: NetworkCacheProtocol {
    /// Shared instance of the cache
    static let shared = InMemoryNetworkCache()
    
    private let cache = NSCache<NSString, CacheEntry>()
    
    /// Dictionary to keep track of cache keys and their timestamps for expiration
    private var timestamps: [String: Date] = [:]
    
    /// Lock for thread safety
    private let lock = NSLock()
    
    /// Initialize the cache with default settings
    init(countLimit: Int = 100) {
        cache.countLimit = countLimit
    }
    
    func contains(key: String) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return cache.object(forKey: key as NSString) != nil
    }
    
    func store(_ data: Data, forKey key: String) {
        lock.lock()
        defer { lock.unlock() }
        
        let entry = CacheEntry(data: data)
        cache.setObject(entry, forKey: key as NSString)
        timestamps[key] = entry.timestamp
        
        print(String(format: AppStrings.Cache.storedInCache, key))
    }
    
    func retrieve(forKey key: String) -> CacheEntry? {
        lock.lock()
        defer { lock.unlock() }
        
        guard let entry = cache.object(forKey: key as NSString) else {
            return nil
        }
        
        return entry
    }
    
    func remove(forKey key: String) {
        lock.lock()
        defer { lock.unlock() }
        
        cache.removeObject(forKey: key as NSString)
        timestamps.removeValue(forKey: key)
        
        print(String(format: AppStrings.Cache.removedFromCache, key))
    }
    
    func removeAll() {
        lock.lock()
        defer { lock.unlock() }
        
        cache.removeAllObjects()
        timestamps.removeAll()
        
        print(AppStrings.Cache.clearedAllCache)
    }
    
    @discardableResult
    func removeExpired(maxAge: TimeInterval) -> Int {
        lock.lock()
        defer { lock.unlock() }
        
        let now = Date()
        let expiredKeys = timestamps.filter { now.timeIntervalSince($0.value) > maxAge }.keys
        
        for key in expiredKeys {
            cache.removeObject(forKey: key as NSString)
            timestamps.removeValue(forKey: key)
        }
        
        if !expiredKeys.isEmpty {
            print(String(format: AppStrings.Cache.removedExpiredEntries, expiredKeys.count))
        }
        
        return expiredKeys.count
    }
} 