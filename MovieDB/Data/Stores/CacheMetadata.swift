//
//  CacheMetadata.swift
//  MovieDB
//
//  Created by Jhon Lopez on 8/3/25.
//

import Foundation
import SwiftData

@Model
final class CacheMetadata {
    @Attribute(.unique) var key: String
    var lastRefreshed: Date
    
    init(key: String, lastRefreshed: Date) {
        self.key = key
        self.lastRefreshed = lastRefreshed
    }
}
