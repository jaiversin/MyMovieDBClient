
//
//  FavoriteMoviesViewModel.swift
//  MovieDB
//
//  Created by Jhon Lopez on 8/2/25.
//

import Foundation
import Observation

@Observable
final class FavoriteMoviesViewModel {
    @ObservationIgnored
    @Injected(\.presentationDependencies.movieRepository) private var movieRepository: MovieRepository
    @ObservationIgnored
    @Injected(\.presentationDependencies.favoritesStore) private var favoritesStore: FavoritesStore
    
    var favoriteMovies: [Movie] = []
    var isLoading: Bool = false
    var errorMessage: String?
    
    @MainActor
    func fetchFavoriteMovies() async {
        isLoading = true
        errorMessage = nil
        
        let favoriteIDs = favoritesStore.favoriteMovieIDs
        if favoriteIDs.isEmpty {
            favoriteMovies = []
            isLoading = false
            return
        }
        
        var movies: [Movie] = []
        
        do {
            // Using a task group to fetch movie details concurrently
            try await withThrowingTaskGroup(of: Movie.self) { group in
                for id in favoriteIDs {
                    group.addTask {
                        try await self.movieRepository.getMovieDetails(id: id)
                    }
                }
                
                for try await movie in group {
                    movies.append(movie)
                }
            }
            favoriteMovies = movies.sorted { $0.title < $1.title } // Sort for a consistent order
        } catch {
            errorMessage = "Failed to fetch favorite movies: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
