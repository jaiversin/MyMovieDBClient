
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
    func getMovieDetails(id: Int) async throws -> Movie
}
