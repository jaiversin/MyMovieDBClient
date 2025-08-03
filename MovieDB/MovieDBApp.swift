
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
        do {
            let schema = Schema([
                PersistentMovie.self,
            ])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            DependenciesContainer.shared = DependenciesContainer(modelContainer: modelContainer)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
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
