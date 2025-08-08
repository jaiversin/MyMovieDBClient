//
//  DependenciesContainer.swift
//  MovieDB
//
//  Created by Jhon Lopez on 8/2/25.
//
import Foundation
import SwiftData

struct DependenciesContainer {
    
    static var shared: DependenciesContainer!
    
    struct PresentationDependencies {
        var movieRepository: MovieRepository
        let favoritesStore: FavoritesStore
    }
    
    struct DataDependencies {
        let cache: CacheStore<NSString, MovieArrayWrapper>
        let popularMoviesCache: PaginatedCacheStore
        let swiftDataContainer: ModelContainer
    }
    
    var presentationDependencies: PresentationDependencies
    let dataDependencies: DataDependencies
    
    init(modelContainer: ModelContainer) {
        let movieService = MovieService()
        
        self.dataDependencies = DataDependencies(
            cache: CacheStore<NSString, MovieArrayWrapper>(),
            popularMoviesCache: PaginatedCacheStore(),
            swiftDataContainer: modelContainer
        )
        
        self.presentationDependencies = PresentationDependencies(
            movieRepository: DefaultMovieRepository(movieService: movieService, swiftDataStore: modelContainer),
            favoritesStore: FavoritesStore()
        )
    }
}
