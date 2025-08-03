//
//  MovieListViewModel.swift
//  MovieDB
//
//  Created by Jhon Lopez on 7/25/25.
//

import Foundation
import Observation
import Combine

@Observable class MovieListViewModel {
    // MARK: - Injected Properties
    @ObservationIgnored
    @Injected(\.presentationDependencies.movieRepository) private var movieRepository: MovieRepository

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
        print("deinit MovieListViewModel")
    }

    // MARK: - Public API

    @MainActor
    func fetchInitialMovies() async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        currentPage = 1
        canLoadMorePages = true
        
        do {
            let fetchedMovies = try await movieRepository.getPopularMovies(page: currentPage)
            popularMovies = fetchedMovies
            filteredMovies = fetchedMovies
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
            
            // Create a set of existing IDs for efficient lookup
            let existingIDs = Set(self.popularMovies.map { $0.id })
            
            // Filter out any movies we already have
            let uniqueNewMovies = fetchedMovies.filter { !existingIDs.contains($0.id) }
            
            if uniqueNewMovies.isEmpty {
                // If the API returns no *new* movies, stop paginating
                canLoadMorePages = false
            } else {
                popularMovies.append(contentsOf: uniqueNewMovies)
                filteredMovies.append(contentsOf: uniqueNewMovies)
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
