//
//  MockMovieService.swift
//  MovieDBTests
//
//  Created by Jhon Lopez on 8/3/25.
//

import Foundation
@testable import MovieDB

class MockMovieService: MovieServiceProtocol {
    var popularMoviesResult: Result<[Movie], Error>?
    var searchMoviesResult: Result<[Movie], Error>?
    var movieDetailsResult: Result<Movie, Error>?
    var movieTrailerResult: Result<Video?, Error>?

    func fetchPopularMovies(page: Int, forceRefresh: Bool) async throws -> [Movie] {
        return try popularMoviesResult!.get()
    }

    func searchMovies(query: String) async throws -> [Movie] {
        return try searchMoviesResult!.get()
    }

    func getMovieDetails(id: Int) async throws -> Movie {
        return try movieDetailsResult!.get()
    }

    func getMoviesTrailer(movieId: Int) async throws -> Video? {
        return try movieTrailerResult!.get()
    }
}
