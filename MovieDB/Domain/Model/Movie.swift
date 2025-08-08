//
//  Movie.swift
//  MovieDB
//
//  Created by Jhon Lopez on 7/24/25.
//

import Foundation

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
    let voteAverage: Double
    
    var posterPathURL: URL? { MovieConstants.posterBaseURL?.appending(path: posterPath ?? "") }
    
    var starsAverage: Int { Int(voteAverage / 2) }
}

extension Movie {
    static func mockMovies() -> [Movie] {
        let movie1 = Movie(id: 1,
                           overview: "This is a sample overview of the movie. It describes the plot, the characters, and the main themes of the film. It's a great movie, you should watch it.",
                           title: "Great Movie Title",
                           posterPath: "/c32TsWLES7kL1uy6fF03V67AIYX.jpg",
                           releaseDate: "2025-06-10",
                           voteAverage: 9)
        let movie2 = Movie(id: 2,
                           overview: "Another overview here",
                           title: "Nice Movie Title",
                           posterPath: "/c32TsWLES7kL1uy6fF03V67AIYX.jpg",
                           releaseDate: "2025-07-10",
                           voteAverage: 4)
        return [movie1, movie2]
    }
}
