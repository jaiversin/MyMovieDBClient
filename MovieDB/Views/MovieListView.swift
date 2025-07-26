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
    @StateObject var viewModel: MovieListViewModel = .init()
    private let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    
//    init(viewModel: MovieListViewModel) {
//        self.viewModel = viewModel
//    }
    
    var body: some View {
        NavigationStack {
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
                            ForEach(viewModel.movies) { movie in
                                NavigationLink(destination: MovieDetailView(movie: movie)) {
                                    MovieCard(movie: movie)
                                }
                                .buttonStyle(.plain) // This prevents the whole card from turning blue
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .navigationTitle("Popular Movies")
                .task {
                    await viewModel.fetchPopularMovies()
                }
            }
        }
    }
}

#Preview {
    MovieListView()
}
