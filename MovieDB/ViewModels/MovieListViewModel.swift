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
        let debouncedSearchPublisher = searchSubject
            .debounce(for: 0.5, scheduler: DispatchQueue.main) // Same as using RunLoop.main, difference is RunLoop is a higher-level abstraction that manages event sources for th emain thread.
            .removeDuplicates()
        
        debouncedSearchPublisher
            .combineLatest(moviesSubject)
            .map { [weak self] (query, movies) -> [Movie] in
                guard let self else { return [] }
                
                let trimmedQuery = query.trimmingCharacters(in: .whitespaces)
                
                if trimmedQuery.isEmpty {
                    return movies
                }
                
                return self.movies.filter { $0.title.localizedCaseInsensitiveContains(trimmedQuery) }
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (movies) in
                self?.filteredMovies = movies
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
