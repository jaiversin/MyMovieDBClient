//
//  MovieListViewModel.swift
//  MovieDB
//
//  Created by Jhon Lopez on 7/25/25.
//

import Foundation
import Observation

@Observable class MovieListViewModel {
    var movies: [Movie] = []
    var errorMessage: String?
    var isLoading: Bool = false
    
    private let movieService: MovieService
//    private var cancellables: Set<AnyCancellable> = []
    
    init(movieService: MovieService = MovieService()) {
        self.movieService = movieService
    }
    
    deinit {
        print("deinit MovieListViewModel")
//        cancellables.forEach(\.cancel)
    }
    
    @MainActor
    func fetchPopularMovies() async {
        defer {
            isLoading = false
        }
        isLoading = true
        errorMessage = nil
        
        do {
            movies = try await movieService.fetchPopularMovies()
        } catch {
            errorMessage = "Failed to fetch movies: \(error)"
        }
    }
    
}
