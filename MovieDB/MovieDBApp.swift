
//
//  MovieDBApp.swift
//  MovieDB
//
//  Created by Jhon Lopez on 7/24/25.
//

import SwiftUI
import SwiftData

@main
struct MovieDBApp: App {
//    @State private var movieListViewModel = MovieListViewModel()
    
    let modelContainer: ModelContainer
    
    init() {
        if ProcessInfo.processInfo.arguments.contains("-testing") {
            // In testing, the test case will set up the container.
            // We must still initialize the property to satisfy the compiler.
            self.modelContainer = try! ModelContainer(for: PersistentMovie.self, configurations: .init(isStoredInMemoryOnly: true))
        } else {
            // For production, set up the real container and shared dependencies.
            do {
                let schema = Schema([
                    PersistentMovie.self,
                    CacheMetadata.self,
                ])
                let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
                let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
                self.modelContainer = container
                DependenciesContainer.shared = DependenciesContainer(modelContainer: container)
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            MovieListView()
//                .environment(movieListViewModel)
        }
        .modelContainer(modelContainer)
    }
}
