//
//  PopularMoviesView.swift
//  MovieDB
//
//  Created by Jhon Lopez on 7/29/25.
//
import SwiftUI

struct PopularMoviesView: View {
    @State private var viewModel = PopularMoviesViewModel()
    private let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    
    @State private var searchText: String = ""
    var body: some View {
        ScrollView {
            ZStack {
                // This could be better handled by an enum with possible states of the view and a switch
                if viewModel.isLoading {
                    ProgressView {
                        Text("Loading...")
                    }
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.headline)
                        .foregroundStyle(.red)
                        .padding()
                } else {
                    LazyVGrid(columns: columns, spacing: 15) {
                        ForEach(viewModel.filteredMovies) { movie in
                            NavigationLink(destination: MovieDetailView(movie: movie)) {
                                MovieCardView(movie: movie)
                            }
                            .buttonStyle(.plain) // This prevents the whole card from turning blue
                            .onAppear {
                                // Option 1 for infinite scrolling
                                // Trade-offs: Does not need Geometry reader or screen position
                                // But calls the function for every movie
                                viewModel.fetchMoreMoviesIfNeeded(movie.id)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
        }
        .navigationTitle("Popular Movies")
        .searchable(text: $searchText, prompt: "Search")
        .onChange(of: searchText) { _, newValue in
            viewModel.searchQuery = newValue
        }
//            .searchable(debouncingBy: 0.5) { value in
//                movieListViewModel.searchQuery = value
//            }
        .task {
            if viewModel.filteredMovies.isEmpty {
                await viewModel.fetchInitialMovies()
            }
        }
        .refreshable {
            await viewModel.fetchInitialMovies()
        }
    }
}
