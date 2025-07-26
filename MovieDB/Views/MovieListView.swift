//
//  MovieListView.swift
//  MovieDB
//
//  Created by Jhon Lopez on 7/25/25.
//

import SwiftUI

struct MovieListView: View {
    // Use ObservedObject when it needs to be injected (used by more than one view or created by the parent)
//    @ObservedObject var viewModel: MovieListViewModel
//    @Environment var viewModel: MovieListViewModel
    var body: some View {
        NavigationStack {
            TabView {
                PopularMoviesView()
                    .tabItem {
                        Image(systemName: "movieclapper")
                        Text("Popular")
                    }
                NavigationStack {
                    FavoriteMoviesView()
                }
                .tabItem {
                    Image(systemName: "heart.rectangle.fill")
                    Text("Favorites")
                }
                
            }
        }
    }
}

#Preview {
    MovieListView()
        .environment(FavoritesStore())
        .environment(MovieListViewModel())
}

struct FavoriteMoviesView: View {
    @Environment(FavoritesStore.self) private var favoritesStore
    @Environment(MovieListViewModel.self) private var movieListViewModel
    
    private let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    
    private var favoriteMovies: [Movie] {
        let filtered = movieListViewModel.movies.filter { favoritesStore.isFavorite(movieId: $0.id) }
        print("Favorites: \(filtered)")
        return filtered
    }
    
    var body: some View {
        ScrollView {
            if favoriteMovies.isEmpty {
                Text("No favorites yet")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .padding()
            } else {
                // Don't duplicate, extract this view
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(favoriteMovies) { movie in
                        NavigationLink(destination: MovieDetailView(movie: movie)) {
                            MovieCardView(movie: movie)
                        }
                        .buttonStyle(.plain) // This prevents the whole card from turning blue
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Favorites")
    }
}

struct PopularMoviesView: View {
    @Environment(MovieListViewModel.self) private var movieListViewModel
    private let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    
    var body: some View {
        ScrollView {
            ZStack {
                // This could be better handled by an enum with possible states of the view and a switch
                if movieListViewModel.isLoading {
                    ProgressView {
                        Text("Loading...")
                    }
                } else if let errorMessage = movieListViewModel.errorMessage {
                    Text(errorMessage)
                        .font(.headline)
                        .foregroundStyle(.red)
                        .padding()
                } else {
                    LazyVGrid(columns: columns, spacing: 15) {
                        ForEach(movieListViewModel.movies) { movie in
                            NavigationLink(destination: MovieDetailView(movie: movie)) {
                                MovieCardView(movie: movie)
                            }
                            .buttonStyle(.plain) // This prevents the whole card from turning blue
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Popular Movies")
            .task {
                if movieListViewModel.movies.isEmpty {
                    await movieListViewModel.fetchPopularMovies()
                }
            }
        }
    }
}
