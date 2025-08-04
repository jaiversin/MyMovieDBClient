
//
//  MovieRepository.swift
//  MovieDB
//
//  Created by Jhon Lopez on 8/2/25.
//

import Foundation

protocol MovieRepository {
    func getPopularMovies(page: Int) async throws -> [Movie]
    func searchMovies(query: String, page: Int) async throws -> [Movie]
    func getMoviesTrailer(movieId: Int) async throws -> Video?
    func getMovieDetails(id: Int) async throws -> Movie
    func clearPopularMovieCache() async throws
    func isPopularMoviesCacheStale() async -> Bool
    func updatePopularMoviesCacheTimestamp() async throws
}
