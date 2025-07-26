//
//  MovieListViewModel.swift
//  MovieDB
//
//  Created by Jhon Lopez on 7/25/25.
//

import Foundation
import Combine

@MainActor
class MovieListViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    private let movieService: MovieService
//    private var cancellables: Set<AnyCancellable> = []
    
    init(movieService: MovieService = MovieService()) {
        self.movieService = movieService
    }
    
    deinit {
        print("deinit MovieListViewModel")
//        cancellables.forEach(\.cancel)
    }
    
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
