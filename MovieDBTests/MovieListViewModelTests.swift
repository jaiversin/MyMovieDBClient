
import XCTest
@testable import MovieDB
import SwiftData

@MainActor
class MovieListViewModelTests: XCTestCase {

    var viewModel: PopularMoviesViewModel!
    var mockRepository: MockMovieRepository!
    var inMemoryContainer: ModelContainer!

    override func setUp() {
        super.setUp()
        // 1. Set up the in-memory SwiftData container
        inMemoryContainer = try! ModelContainer(for: PersistentMovie.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        
        // 2. Create the mock repository
        mockRepository = MockMovieRepository(modelContainer: inMemoryContainer)
        
        // 3. Inject the mock repository into the shared DI container
        // This is the key step for making the ViewModel testable
        DependenciesContainer.shared.presentationDependencies.movieRepository = mockRepository
        
        // 4. Initialize the ViewModel. It will now use the mock repository.
        viewModel = PopularMoviesViewModel()
    }

    override func tearDown() {
        // Reset the repository to avoid side-effects in other tests
        mockRepository.clearAllData()
        
        // Deallocate objects
        viewModel = nil
        mockRepository = nil
        inMemoryContainer = nil
        
        super.tearDown()
    }

    func test_fetchInitialMovies_success() async {
        // Given
        let expectedMovies = [TestData.movie1, TestData.movie2]
        mockRepository.stubbedPopularMovies = .success(expectedMovies)

        // When
        await viewModel.fetchInitialMovies()

        // Then
        XCTAssertEqual(viewModel.filteredMovies.count, 2)
        XCTAssertEqual(viewModel.filteredMovies, expectedMovies)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }

    func test_fetchInitialMovies_failure() async {
        // Given
        let expectedError = URLError(.notConnectedToInternet)
        mockRepository.stubbedPopularMovies = .failure(expectedError)

        // When
        await viewModel.fetchInitialMovies()

        // Then
        XCTAssertTrue(viewModel.filteredMovies.isEmpty)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, "Failed to fetch movies: \(expectedError.localizedDescription)")
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func test_fetchNextPageMovies_appendsNewMoviesCorrectly() async {
        // Given: Initial fetch is successful
        let initialMovies = [TestData.movie1, TestData.movie2]
        mockRepository.stubbedPopularMovies = .success(initialMovies)
        await viewModel.fetchInitialMovies()
        
        // Ensure initial state is correct
        XCTAssertEqual(viewModel.filteredMovies.count, 2)
        
        // Given: The next page has new movies
        let nextPageMovies = [TestData.movie3]
        mockRepository.stubbedPopularMovies = .success(nextPageMovies)
        
        // When
        await viewModel.fetchNextPageMovies()
        
        // Then
        XCTAssertEqual(viewModel.filteredMovies.count, 3, "Should contain initial movies + new page movies")
        XCTAssertEqual(viewModel.filteredMovies, initialMovies + nextPageMovies, "The combined list of movies should be correct")
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func test_fetchNextPageMovies_doesNotAddDuplicates() async {
        // Given: Initial fetch is successful
        let initialMovies = [TestData.movie1, TestData.movie2]
        mockRepository.stubbedPopularMovies = .success(initialMovies)
        await viewModel.fetchInitialMovies()
        
        // Ensure initial state is correct
        XCTAssertEqual(viewModel.filteredMovies.count, 2)
        
        // Given: The next page contains a duplicate movie
        let nextPageMoviesWithDuplicate = [TestData.movie2, TestData.movie3]
        mockRepository.stubbedPopularMovies = .success(nextPageMoviesWithDuplicate)
        
        // When
        await viewModel.fetchNextPageMovies()
        
        // Then
        XCTAssertEqual(viewModel.filteredMovies.count, 3, "Should only add the unique movie")
        XCTAssertTrue(viewModel.filteredMovies.contains(TestData.movie1), "Should still contain movie 1")
        XCTAssertTrue(viewModel.filteredMovies.contains(TestData.movie2), "Should still contain movie 2")
        XCTAssertTrue(viewModel.filteredMovies.contains(TestData.movie3), "Should have added movie 3")
        XCTAssertNil(viewModel.errorMessage)
    }
}
