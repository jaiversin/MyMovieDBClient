//
//  CacheStore.swift
//  MovieDB
//
//  Created by Jhon Lopez on 7/29/25.
//

import Foundation
import OSLog

final class CacheStore<Key: NSObject, Value: AnyObject> {
    private let cache = NSCache<Key, Value>()
    
    func set(_ value: Value, forKey key: Key) {
        cache.setObject(value, forKey: key)
    }
    
    func object(forKey key: Key) -> Value? {
        cache.object(forKey: key)
    }
}

final class PaginatedCacheStore {
    private let cache = NSCache<NSString, MovieArrayWrapper>()
    
    private var keys: Set<NSString> = []
    
    func set(_ value: MovieArrayWrapper, forKey key: NSString) {
        cache.setObject(value, forKey: key)
        keys.insert(key)
    }
    
    func getObject(forKey key: NSString) -> MovieArrayWrapper? {
        return cache.object(forKey: key)
    }
    
    func invalidateAll() {
        Logger.movieDB.log("Invalidating all cache entries...")
        keys.forEach { cache.removeObject(forKey: $0) }
        keys.removeAll()
    }
    
}

/// Wrapper class for the Movies array, as NSCache can only store Objects (classes) and not structs or value types.
final class MovieArrayWrapper: NSObject {
    let movies: [Movie]
    
    init(movies: [Movie]) {
        self.movies = movies
    }
}
