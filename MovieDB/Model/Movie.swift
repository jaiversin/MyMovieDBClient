//
//  Movie.swift
//  MovieDB
//
//  Created by Jhon Lopez on 7/24/25.
//

struct MovieResponse: Decodable {
    let results: [Movie]
}

struct Movie: Decodable, Identifiable {
    let id: Int
    let overview: String
    let title: String
    // Note we'll use keyDecodingStrategy on the JSONDecoder to let it convert from snake case into camel case
    let posterPath: String?
    let releaseDate: String?
}
