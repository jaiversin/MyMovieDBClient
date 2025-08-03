//
//  FavoriteMoviesView.swift
//  MovieDB
//
//  Created by Jhon Lopez on 7/29/25.
//
import SwiftUI

struct FavoriteMoviesView: View {
    @Environment(FavoritesStore.self) private var favoritesStore
    @Environment(MovieListViewModel.self) private var movieListViewModel
    
    private let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    
    private var favoriteMovies: [Movie] {
        movieListViewModel.movies.filter { favoritesStore.isFavorite(movieId: $0.id) }
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
