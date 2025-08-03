//
//  FavoriteMoviesView.swift
//  MovieDB
//
//  Created by Jhon Lopez on 7/29/25.
//
import SwiftUI

struct FavoriteMoviesView: View {
    @State private var viewModel = FavoriteMoviesViewModel()
    
    private let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    
    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView()
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else if viewModel.favoriteMovies.isEmpty {
                Text("No favorites yet")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .padding()
            } else {
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(viewModel.favoriteMovies) { movie in
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
        .task {
            await viewModel.fetchFavoriteMovies()
        }
    }
}
