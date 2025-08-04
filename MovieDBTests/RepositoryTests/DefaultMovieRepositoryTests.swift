//
//  DefaultMovieRepositoryTests.swift
//  MovieDBTests
//
//  Created by Jhon Lopez on 8/3/25.
//

import XCTest
import SwiftData
@testable import MovieDB

final class DefaultMovieRepositoryTests: XCTestCase {

    var mockMovieService: MockMovieService!
    var inMemoryContainer: ModelContainer!
    var repository: DefaultMovieRepository!

    @MainActor
    override func setUp() {
        super.setUp()
        mockMovieService = MockMovieService()
        
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        inMemoryContainer = try! ModelContainer(for: PersistentMovie.self, CacheMetadata.self, configurations: config)
        
        // When testing, we manually create and set the shared container.
        DependenciesContainer.shared = DependenciesContainer(modelContainer: inMemoryContainer)
        
        repository = DefaultMovieRepository(movieService: mockMovieService, swiftDataStore: inMemoryContainer)
    }

    override func tearDown() {
        mockMovieService = nil
        inMemoryContainer = nil
        repository = nil
        super.tearDown()
    }

    @MainActor
    func test_getPopularMovies_whenDatabaseIsEmpty_shouldFetchFromNetworkAndSave() async throws {
        // Given
        let mockMovies = Movie.mockMovies()
        mockMovieService.popularMoviesResult = .success(mockMovies)

        // When
        let fetchedMovies = try await repository.getPopularMovies(page: 1)

        // Then
        XCTAssertEqual(fetchedMovies.count, mockMovies.count)
        
        // Verify that the movies were saved to the database
        let descriptor = FetchDescriptor<PersistentMovie>()
        let persistedMovies = try inMemoryContainer.mainContext.fetch(descriptor)
        XCTAssertEqual(persistedMovies.count, mockMovies.count)
    }

    @MainActor
    func test_getPopularMovies_whenCacheIsPopulated_shouldFetchFromDatabase() async throws {
        // Given
        let cachedMovie = PersistentMovie(id: 123, overview: "Cached Movie", title: "Cached Title", posterPath: nil, releaseDate: nil, voteAverage: 8.0)
        inMemoryContainer.mainContext.insert(cachedMovie)

        // Set the mock service to return an error to ensure it's not called
        mockMovieService.popularMoviesResult = .failure(URLError(.badServerResponse))

        // When
        let fetchedMovies = try await repository.getPopularMovies(page: 1)

        // Then
        XCTAssertEqual(fetchedMovies.count, 1)
        XCTAssertEqual(fetchedMovies.first?.id, 123)
        XCTAssertEqual(fetchedMovies.first?.title, "Cached Title")
    }

    @MainActor
    func test_cacheStaleness_and_clearing() async throws {
        // Given: A stale cache metadata entry
        let staleDate = Calendar.current.date(byAdding: .hour, value: -7, to: Date())!
        let metadata = CacheMetadata(key: "popularMovies", lastRefreshed: staleDate)
        inMemoryContainer.mainContext.insert(metadata)

        // When: Checking for staleness
        let isStale = await repository.isPopularMoviesCacheStale()

        // Then: It should be considered stale
        XCTAssertTrue(isStale)

        // Given: A fresh cache metadata entry
        let freshDate = Date()
        metadata.lastRefreshed = freshDate
        try inMemoryContainer.mainContext.save()

        // When: Checking for staleness again
        let isFresh = await repository.isPopularMoviesCacheStale()

        // Then: It should not be considered stale
        XCTAssertFalse(isFresh)

        // When: Clearing the cache
        try await repository.clearPopularMovieCache()

        // Then: The database should be empty
        let descriptor = FetchDescriptor<CacheMetadata>()
        let count = try inMemoryContainer.mainContext.fetchCount(descriptor)
        XCTAssertEqual(count, 0)
    }
}
