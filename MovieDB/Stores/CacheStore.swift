//
//  CacheStore.swift
//  MovieDB
//
//  Created by Jhon Lopez on 7/29/25.
//

import Foundation

final class CacheStore<Key: NSObject, Value: AnyObject> {
    private let cache = NSCache<Key, Value>()
    
    func set(_ value: Value, forKey key: Key) {
        cache.setObject(value, forKey: key)
    }
    
    func object(forKey key: Key) -> Value? {
        cache.object(forKey: key)
    }
}

/// Wrapper class for the Movies array, as NSCache can only store Objects (classes) and not structs or value types.
final class MovieArrayWrapper: NSObject {
    let movies: [Movie]
    
    init(movies: [Movie]) {
        self.movies = movies
    }
}
