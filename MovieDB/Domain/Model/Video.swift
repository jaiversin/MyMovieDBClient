//
//  Video.swift
//  MovieDB
//
//  Created by Jhon Lopez on 7/25/25.
//

import Foundation

struct VideoResponse: Codable {
    let results: [Video]
}

struct Video: Codable, Identifiable {
    let id: String
    let key: String // Youtube video id
    let site: String
    let type: String
    
    var isTrailerOnYoutube: Bool {
        type == "Trailer" && site == "YouTube"
    }
    
    var youtubeURL: URL? {
        URL(string: "https://www.youtube.com/watch?v=\(key)")
    }
}
