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
    @State private var movieListViewModel = MovieListViewModel()
    
//    var sharedModelContainer: ModelContainer = {
//        let schema = Schema([
//            Item.self,
//        ])
//        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
//
//        do {
//            return try ModelContainer(for: schema, configurations: [modelConfiguration])
//        } catch {
//            fatalError("Could not create ModelContainer: \(error)")
//        }
//    }()

    var body: some Scene {
        WindowGroup {
            MovieListView()
//                .environment(favoritesStore)
                .environment(movieListViewModel)
        }
//        .modelContainer(sharedModelContainer)
    }
}
