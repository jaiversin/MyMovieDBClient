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
    var filteredMovies: [Movie] = []
    var errorMessage: String?
    var isLoading: Bool = false
    var currentPage = 1
    var canLoadMorePages = true // Whenever we try to fetch more results and the movies array does not grow, this becomes false
    
    var searchQuery: String = "" {
        didSet { searchSubject.send(searchQuery) }
    }
    
    var movies: [Movie] = [] {
        didSet { moviesSubject.send(movies) }
    }
    
    private let searchSubject = PassthroughSubject<String, Never>()
    private let moviesSubject = PassthroughSubject<[Movie], Never>()
    private var cancellables: Set<AnyCancellable> = []
    private var isFetchingNextPage = false
    
    fileprivate func setupSearchSubscription() {
        searchSubject
            .debounce(for: 0.5, scheduler: DispatchQueue.main) // Same as using RunLoop.main, difference is RunLoop is a higher-level abstraction that manages event sources for th emain thread.
            .removeDuplicates()
            .map { [weak self] query -> AnyPublisher<[Movie], Never> in
                guard let self else {
                    // either case works as an empty response
                    return Just([]).eraseToAnyPublisher()
//                    return Empty<[Movie], Never>().eraseToAnyPublisher()
                }
                
                let trimmedQuery = query.trimmingCharacters(in: .whitespaces)
                if trimmedQuery.isEmpty {
                    return Just(self.movies).eraseToAnyPublisher()
                } else {
                    return MovieService.shared.searchMoviesPublisher(query: trimmedQuery)
                        .catch { error -> Just<[Movie]> in
                            print("Error searching movies: \(error)")
                            return Just([])
                        }
                        .eraseToAnyPublisher()
                }
                
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (searchResultMovies) in
                self?.filteredMovies = searchResultMovies
            }
            .store(in: &cancellables)
    }
    
    init() {
        setupSearchSubscription()
    }
    
    deinit {
        print("deinit MovieListViewModel")
        cancellables.removeAll()
    }
    
    @MainActor
    func fetchPopularMovies() async {
        defer {
            isLoading = false
        }
        currentPage = 1
        canLoadMorePages = true
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedMovies = try await MovieService.shared.fetchPopularMovies(page: 1, forceRefresh: true)
            movies = fetchedMovies
            filteredMovies = fetchedMovies
        } catch {
            errorMessage = "Failed to fetch movies: \(error)"
        }
    }
    
    @MainActor
    func fetchNextPageMovies() async {
        guard isFetchingNextPage == false, canLoadMorePages else { return }
        
        defer {
            isFetchingNextPage = false
        }
        isFetchingNextPage = true
        currentPage += 1
        
        do {
            let fetchedMovies = try await MovieService.shared.fetchPopularMovies(page: currentPage)
            movies.append(contentsOf: fetchedMovies)
            filteredMovies.append(contentsOf: fetchedMovies)
            canLoadMorePages = fetchedMovies.count > 0
        } catch {
            currentPage -= 1 // Give the user a chance to re-try
            errorMessage = "Failed to fetch movies: \(error.localizedDescription)"
        }
    }
    
    func fetchMoreMoviesIfNeeded(_ movieId: Int) {
        guard !filteredMovies.isEmpty else { return }
        
        let threshold: Int = 4 // candidate to be a constant or a centralized setting so all lists behave the same
        let thresholdIndex = filteredMovies.count - threshold
        
        if let movieIndex = filteredMovies.firstIndex(where: { $0.id == movieId }) {
            if movieIndex >= thresholdIndex {
                Task {
                    await fetchNextPageMovies()
                }
            }
        }
    }
    
}
