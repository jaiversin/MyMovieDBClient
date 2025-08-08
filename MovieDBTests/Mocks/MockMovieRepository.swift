
import Foundation
@testable import MovieDB
import SwiftData

// A mock repository that allows for stubbing network responses and errors
@MainActor
class MockMovieRepository: MovieRepository {
    var modelContainer: ModelContainer
    var stubbedPopularMovies: Result<[Movie], Error>?
    var stubbedMovieTrailer: Result<Video, Error>?
    var stubbedSearchResults: Result<[Movie], Error>?
    var stubbedMovieDetail: Result<Movie, Error>?
    

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    // MARK: - Protocol Conformance

    func getPopularMovies(page: Int) async throws -> [Movie] {
        switch stubbedPopularMovies {
        case .success(let movies):
            return movies
        case .failure(let error):
            throw error
        case .none:
            throw NSError(domain: "MockMovieRepository", code: 0, userInfo: [NSLocalizedDescriptionKey: "getPopularMovies not stubbed"])
        }
    }

    func searchMovies(query: String, page: Int) async throws -> [Movie] {
        switch stubbedSearchResults {
        case .success(let movies):
            return movies
        case .failure(let error):
            throw error
        case .none:
            return [] // Return empty by default for search
        }
    }
    
    func getMoviesTrailer(movieId: Int) async throws -> MovieDB.Video? {
        switch stubbedMovieTrailer {
        case .success(let video):
            return video
        case .failure(let error):
            throw error
        case .none:
            throw NSError(domain: "MockMovieRepository", code: 1, userInfo: [NSLocalizedDescriptionKey: "getMovieTrailer not stubbed"])
        }
    }

    func getMovieDetails(id: Int) async throws -> Movie {
        switch stubbedMovieDetail {
        case .success(let movie):
            return movie
        case .failure(let error):
            throw error
        case .none:
            throw NSError(domain: "MockMovieRepository", code: 1, userInfo: [NSLocalizedDescriptionKey: "getMovieDetails not stubbed"])
        }
    }

    // MARK: - Cache Simulation (Not fully implemented for this mock)

    func isPopularMoviesCacheStale() async -> Bool {
        // For tests, we can assume we always want fresh data unless specified otherwise.
        return true
    }

    func clearPopularMovieCache() async {
        // Simulate clearing the cache
    }

    func updatePopularMoviesCacheTimestamp() async {
        // Simulate updating the timestamp
    }
    
    // MARK: - Test Helpers
    
    func clearAllData() {
        stubbedPopularMovies = nil
        stubbedMovieTrailer = nil
        stubbedSearchResults = nil
    }
}
