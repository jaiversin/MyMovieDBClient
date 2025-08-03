//
//  DependenciesContainer.swift
//  MovieDB
//
//  Created by Jhon Lopez on 8/2/25.
//
import Foundation

struct DependenciesContainer {
    
    struct PresentationDependencies {
        let movieService: MovieService
        let favoritesStore: FavoritesStore
    }
    
    struct DataDependencies {
        let cache: CacheStore<NSString, MovieArrayWrapper>
        let popularMoviesCache: PaginatedCacheStore
    }
    
    private(set) var presentationDependencies: PresentationDependencies
    private(set) var dataDependencies: DataDependencies
    
    // TODO: Check if I can delegate the creation of the assembly to the main app
    static var assembly: DependenciesContainer = {
#if DEBUG
        return DependenciesContainer.assembleRealApp()  // .assembleMockApp()
#else
        return DependenciesContainer.assembleRealApp()
#endif
    }()
    
    static func assembleRealApp() -> DependenciesContainer {
        let vmDependencies = PresentationDependencies(
            movieService: MovieService(),
            favoritesStore: FavoritesStore()
        )

        let dataDependencies = DataDependencies(
            cache: CacheStore<NSString, MovieArrayWrapper>(),
            popularMoviesCache: PaginatedCacheStore()
        )
        
        return .init(presentationDependencies: vmDependencies, dataDependencies: dataDependencies)
    }
}
