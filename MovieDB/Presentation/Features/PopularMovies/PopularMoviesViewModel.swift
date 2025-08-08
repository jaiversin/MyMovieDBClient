//
//  MovieListViewModel.swift
//  MovieDB
//
//  Created by Jhon Lopez on 7/25/25.
//

import Foundation
import OSLog
import Observation
import Combine
import SwiftData

@Observable class PopularMoviesViewModel {
    // MARK: - Injected Properties
    @Injected(\.presentationDependencies.movieRepository) @ObservationIgnored private var movieRepository: MovieRepository

    // MARK: - Published Properties
    var filteredMovies: [Movie] = []
    var errorMessage: String?
    var isLoading: Bool = false
    var searchQuery: String = "" {
        didSet {
            // Debounce search
            searchTask?.cancel()
            let task = Task {
                try await Task.sleep(for: .seconds(0.5))
                await performSearch()
            }
            searchTask = task
        }
    }

    // MARK: - Private Properties
    private var popularMovies: [Movie] = []
    private var currentPage = 1
    private var canLoadMorePages = true
    private var isFetchingNextPage = false
    private var searchTask: Task<Void, Error>?

    init() {}

    deinit {
        searchTask?.cancel()
        Logger.movieDB.info("deinit MovieListViewModel")
    }

    // MARK: - Public API

    @MainActor
    fileprivate func fetchPopularMovies() async throws {
        let fetchedMovies = try await movieRepository.getPopularMovies(page: 1)
        popularMovies = fetchedMovies
        filteredMovies = fetchedMovies
    }
    
    @MainActor
    func fetchInitialMovies() async {
        isLoading = true
        errorMessage = nil
        currentPage = 1
        canLoadMorePages = true
        
        do {
            if await movieRepository.isPopularMoviesCacheStale() {
                try await movieRepository.clearPopularMovieCache()
                try await movieRepository.updatePopularMoviesCacheTimestamp()
            }
            try await fetchPopularMovies()
        } catch {
            errorMessage = "Failed to fetch movies: \(error.localizedDescription)"
        }
        
        isLoading = false
    }

    @MainActor
    func fetchNextPageMovies() async {
        guard !isFetchingNextPage, canLoadMorePages, searchQuery.isEmpty else { return }

        isFetchingNextPage = true
        currentPage += 1

        do {
            let fetchedMovies = try await movieRepository.getPopularMovies(page: currentPage)
            if fetchedMovies.isEmpty {
                canLoadMorePages = false
            } else {
                let existingMovieIDs = Set(popularMovies.map { $0.id })
                let uniqueNewMovies = fetchedMovies.filter { !existingMovieIDs.contains($0.id) }

                if uniqueNewMovies.isEmpty {
                    canLoadMorePages = false
                } else {
                    popularMovies.append(contentsOf: uniqueNewMovies)
                    filteredMovies.append(contentsOf: uniqueNewMovies)
                }
            }
        } catch {
            currentPage -= 1 // Give the user a chance to re-try
            errorMessage = "Failed to fetch next page: \(error.localizedDescription)"
        }
        
        isFetchingNextPage = false
    }

    func fetchMoreMoviesIfNeeded(_ movieId: Int) {
        guard !filteredMovies.isEmpty, searchQuery.isEmpty else { return }

        let threshold = 4
        if let movieIndex = filteredMovies.firstIndex(where: { $0.id == movieId }),
           movieIndex >= filteredMovies.count - threshold {
            Task {
                await fetchNextPageMovies()
            }
        }
    }

    // MARK: - Private Helpers

    @MainActor
    private func performSearch() async {
        let trimmedQuery = searchQuery.trimmingCharacters(in: .whitespaces)
        if trimmedQuery.isEmpty {
            // If search is cleared, show the popular movies again
            filteredMovies = popularMovies
            return
        }

        isLoading = true
        errorMessage = nil
        
        do {
            let searchResults = try await movieRepository.searchMovies(query: trimmedQuery, page: 1)
            filteredMovies = searchResults
        } catch {
            errorMessage = "Failed to search movies: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
