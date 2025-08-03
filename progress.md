# MovieDB App Progress

## Feature: Live Search

We have successfully implemented the live search functionality for the MovieDB app.

### Completed Tasks:

- [x] **Integrate `searchMovies`:** Created a new `searchMoviesPublisher` in `MovieService` to wrap the async function in a Combine `Future`.
- [x] **Update `MovieListViewModel`:** Refactored the view model's Combine pipeline to use `map` and `switchToLatest` for making live API search calls.
- [x] **Refine Search Logic:** The pipeline now debounces user input, handles empty queries by showing popular movies, and gracefully catches network errors.
- [x] **Display Search Results:** The `MovieListView` now correctly displays search results from the API.
- [x] **Bugfix:** Solved an issue where the search bar would disappear by moving the `.searchable()` modifier to a more stable parent view (`ScrollView`).

### Key Learnings:

- Using `map` and `switchToLatest` in Combine to achieve the "flatMapLatest" behavior.
- Wrapping an `async/await` function in a `Future` publisher.
- The importance of attaching SwiftUI modifiers like `.searchable()` to stable parent views.

---

## Feature: Pagination and Advanced Caching

Implemented infinite scrolling for the popular movies list with a robust, multi-layered caching strategy.

### Completed Tasks:

- [x] **Pagination (Infinite Scroll):** The popular movies list now fetches new pages automatically as the user scrolls down.
- [x] **Pull-to-Refresh:** Users can pull down on the list to force a refresh of the latest movies from the network.
- [x] **In-Memory Caching:** Implemented a generic `CacheStore` using `NSCache` to cache API responses for both popular movies and search results.
- [x] **Advanced Cache Invalidation:** Solved a critical data consistency issue by creating a specialized `PaginatedCacheStore` that can invalidate all paginated results at once during a refresh, without affecting the search cache.

### Key Learnings:

- Managing pagination state (current page, loading status) within a ViewModel.
- Using `.onAppear` on a list item to trigger fetching the next page.
- Implementing pull-to-refresh with SwiftUI's `.refreshable` modifier.
- The importance of cache invalidation strategies (`forceRefresh` flag).
- Designing and implementing scoped caches to prevent side effects and ensure data consistency.

---

## Feature: Offline Support & Intelligent Caching

Successfully refactored the app to support offline caching for popular movies using SwiftData and a clean, repository-based architecture with a Time-To-Live (TTL) data freshness strategy.

### Completed Tasks:

- [x] **Architectural Refactor:** Migrated from direct `MovieService` calls to a repository pattern (`MovieRepository` protocol and `DefaultMovieRepository` implementation).
- [x] **SwiftData Integration:** Added `PersistentMovie` and `CacheMetadata` `@Model` classes to store data and caching timestamps locally.
- [x] **DI Container Refactor:** Resolved critical runtime crashes by moving the `ModelContainer` initialization to the `MovieDBApp`'s `init`, ensuring it's created safely on the main thread.
- [x] **View Decoupling:** Created a dedicated `FavoriteMoviesViewModel` to make the favorites view fully independent.
- [x] **Pagination Bugfix:** Corrected the `ForEach` identity crash by implementing duplicate-checking before appending new pages.
- [x] **Intelligent Caching (TTL):** Implemented a 6-hour TTL strategy where the ViewModel uses the repository to check data freshness, clear the cache if stale, and then fetch the latest data, all while abstracting the implementation details from the view.

### Key Learnings:

- **Safe SwiftData Initialization:** The `ModelContainer` must be initialized in a context guaranteed to be on the main thread. The `@main App`'s `init` is the ideal place for this, avoiding crashes seen when using static initializers.
- **Dependency Injection Patterns:** We differentiated between **Initializer Injection** (used for services and repositories to ensure they are decoupled and testable) and **Property Wrapper Injection** (`@Injected`, used in the Presentation layer for clean consumption of pre-built services).
- **ViewModel Purity:** ViewModels should not contain direct data-layer code (e.g., `FetchDescriptor`, direct context access). Their responsibility is to orchestrate by calling high-level, abstracted functions from a repository. This keeps the architecture clean and testable.
- **Protocol-Oriented Design:** When using a protocol-based architecture (like our `MovieRepository`), any new functions must be added to the protocol first, and then implemented in all conforming classes to prevent build failures.
- **Macro and Property Wrapper Interoperability:** Swift's macros (like `@Observable`) can sometimes conflict with property wrappers (`@Injected`). In such cases, using helper attributes like `@ObservationIgnored` is necessary to resolve the conflict and guide the compiler.
- **Robust Pagination:** We learned to handle two key pagination issues: 1) Always check for and filter out duplicate items when appending new pages to prevent SwiftUI `ForEach` identity errors. 2) Defer cache invalidation to a "natural break" (like a new app session or pull-to-refresh) to avoid interrupting a user's active scrolling session.

### Pending and questions:
- [X] Don't use DependenciesContainer.shared?.dataDependencies.swiftDataContainer directly. Inject it using the @Inject property wrapper.
- [x] Do we want to abstract the CacheMetadata fetching into another repository or is it fine, architecturally speaking, to consume it directly from the view model?
- [x] For all the movies data fetching, we should use the repository (through injection with @Injected) and not do the swiftData calls directly from the view model. 
- [x] Can we actually get rid of `// Create a set of existing IDs for efficient lookup` check or are we reintroducing the identity issue?