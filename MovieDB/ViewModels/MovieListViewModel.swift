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
    var searchQuery: String = "" {
        didSet { searchSubject.send(searchQuery) }
    }
    
    var movies: [Movie] = [] {
        didSet { moviesSubject.send(movies) }
    }
    
    private let searchSubject = PassthroughSubject<String, Never>()
    private let moviesSubject = PassthroughSubject<[Movie], Never>()
    
    var filteredMovies: [Movie] = []
    var errorMessage: String?
    var isLoading: Bool = false
    
    private var cancellables: Set<AnyCancellable> = []
    
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
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedMovies = try await MovieService.shared.fetchPopularMovies()
            movies = fetchedMovies
            filteredMovies = fetchedMovies
        } catch {
            errorMessage = "Failed to fetch movies: \(error)"
        }
    }
    
}
