
//
//  DefaultMovieRepository.swift
//  MovieDB
//
//  Created by Jhon Lopez on 8/2/25.
//

import Foundation
import SwiftData

final class DefaultMovieRepository: MovieRepository {
    
    private let movieService: MovieService
    private let swiftDataStore: ModelContainer
    
    init(movieService: MovieService, swiftDataStore: ModelContainer) {
        self.movieService = movieService
        self.swiftDataStore = swiftDataStore
    }
    
    @MainActor
    func getPopularMovies(page: Int) async throws -> [Movie] {
        
        let voteAverageSortDescriptor = SortDescriptor(\PersistentMovie.voteAverage, order: .reverse)
        var descriptor = FetchDescriptor<PersistentMovie>(sortBy: [voteAverageSortDescriptor])
        descriptor.fetchLimit = 20
        descriptor.fetchOffset = page * 20

        let persistedMovies = try? swiftDataStore.mainContext.fetch(descriptor)
        
        if let persistedMovies, !persistedMovies.isEmpty {
            return persistedMovies.map { MovieMapper.toDomain(model: $0) }
        }
        
        let popularMovies = try await movieService.fetchPopularMovies(page: page)
        
        for movie in popularMovies {
            let persistentMovie = MovieMapper.toPersistent(model: movie)
            swiftDataStore.mainContext.insert(persistentMovie)
        }
        
        try? swiftDataStore.mainContext.save()
        
        return popularMovies
    }
    
    @MainActor
    func searchMovies(query: String, page: Int) async throws -> [Movie] {
        let searchedMovies = try await movieService.searchMovies(query: query)
        // We don't cache search results for now
        return searchedMovies
    }

    @MainActor
    func getMovieDetails(id: Int) async throws -> Movie {
        // First, try to fetch from the local SwiftData store
        let fetchDescriptor = FetchDescriptor<PersistentMovie>(
            predicate: #Predicate { $0.id == id }
        )
        
        if let persistedMovie = try? swiftDataStore.mainContext.fetch(fetchDescriptor).first {
            return MovieMapper.toDomain(model: persistedMovie)
        }

        // If not found locally, fetch from the network
        let movie = try await movieService.getMovieDetails(id: id)
        
        // Save the fetched movie to the local store
        let persistentMovie = MovieMapper.toPersistent(model: movie)
        swiftDataStore.mainContext.insert(persistentMovie)
        try? swiftDataStore.mainContext.save()
        
        return movie
    }
}
