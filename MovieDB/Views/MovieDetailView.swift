//
//  MovieDetail.swift
//  MovieDB
//
//  Created by Jhon Lopez on 7/25/25.
//

import SwiftUI
import Observation

@Observable
final class MovieDetailVewModel {
    // Inject this dependency later using the Injected property wrapper
//    private let movieService = MovieService()
    var trailerURL: URL?
    let movie: Movie
    
    init(movie: Movie) {
        self.movie = movie
    }
    
    deinit {
//        print("Movie Detail ViewModel for \(movie.title) deinitialized")
    }
    
    func getMoviesTrailer() async {
        do {
            let video = try await MovieService.shared.getMoviesTrailer(movieId: movie.id)
            if let url = video?.youtubeURL {
                trailerURL = url
            }
        } catch {
            print("Unable to fetch trailer URL")
        }
    }
}

struct MovieDetailView: View {
    @Environment(FavoritesStore.self) private var favoritesStore
    
    @State private var viewModel: MovieDetailVewModel
    @State private var isTrailerVisible: Bool = false
    
    init(movie: Movie) {
        _viewModel = State(initialValue: MovieDetailVewModel(movie: movie))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                AsyncImage(url: viewModel.movie.posterPathURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    
                } placeholder: {
                    Rectangle()
                        .foregroundStyle(.gray.opacity(0.1))
                        .aspectRatio(2/3, contentMode: .fit)
                        .overlay {
                            ProgressView()
                        }
                }
                .overlay {
                    if viewModel.trailerURL != nil {
                        Button(action: {
                            isTrailerVisible = true
                        }) {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 80))
                                .foregroundStyle(.white.opacity(0.6))
                                .shadow(radius: 10)
                        }
                    }
                }
                HStack {
                    Text("Overview")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Spacer()
                    // create a starts base rating usinge voteAverage
                    VStack {
                        HStack(alignment: .center, spacing: 1) {
                            ForEach(0..<Int(viewModel.movie.voteAverage / 2)) { _ in
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                    .font(.system(size: 12))
                            }
                        }
                        .font(.caption2)
                        .padding(.top, 8)
                        Button {
                            favoritesStore.toggleFavorite(movieID: viewModel.movie.id)
                        } label: {
                            Image(systemName: favoritesStore.isFavorite(movieId: viewModel.movie.id) ? "heart.fill" : "heart")
                        }
                        .padding(.vertical, 7)
                    }
                }
                
                if let releaseDate = viewModel.movie.releaseDate {
                    Text(releaseDate)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .foregroundStyle(.gray)
                }
                
                Text(viewModel.movie.overview)
                    .font(.body)
                    .lineLimit(nil)
                    .padding(.top)
            }
            .padding()
        }
        .navigationTitle(viewModel.movie.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.getMoviesTrailer()
        }
        .sheet(isPresented: $isTrailerVisible) {
            if let trailerURL = viewModel.trailerURL {
                SafariView(url: trailerURL)
            }
        }
    }
    
//    private func loadTrailer() async {
//        do {
//            trailerURL =  try await MovieService.shared.getMoviesTrailer(movieId: movie.id)?.youtubeURL
//        } catch {
//            print("Failed to fetch video: \(error.localizedDescription)")
//        }
//    }
}

#Preview {
    NavigationStack {
        MovieDetailView(movie: Movie.mockMovies()[0])
            .environment(FavoritesStore())
    }
}
