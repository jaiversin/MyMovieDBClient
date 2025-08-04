//
//  MovieServiceProtocol.swift
//  MovieDB
//
//  Created by Jhon Lopez on 8/3/25.
//

import Foundation

protocol MovieServiceProtocol {
    func fetchPopularMovies(page: Int, forceRefresh: Bool) async throws -> [Movie]
    func searchMovies(query: String) async throws -> [Movie]
    func getMovieDetails(id: Int) async throws -> Movie
    func getMoviesTrailer(movieId: Int) async throws -> Video?
}
