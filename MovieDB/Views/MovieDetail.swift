//
//  MovieDetail.swift
//  MovieDB
//
//  Created by Jhon Lopez on 7/25/25.
//

import SwiftUI

struct MovieDetailView: View {
    let movie: Movie
    private let movieService = MovieService() // Inject this dependency later using the Injected property wrapper
    @State private var trailerURL: URL?
    @State private var isTrailerVisible: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                AsyncImage(url: movie.posterPathURL) { image in
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
                    if trailerURL != nil {
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
                    HStack(alignment: .center, spacing: 1) {
                        ForEach(0..<Int(movie.voteAverage / 2)) { _ in
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.system(size: 12))
                        }
                    }
                    .font(.caption2)
                }
                
                if let releaseDate = movie.releaseDate {
                    Text(releaseDate)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .foregroundStyle(.gray)
                }
                
                Text(movie.overview)
                    .font(.body)
                    .lineLimit(nil)
                    .padding(.top)
            }
            .padding()
        }
        .navigationTitle(movie.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadTrailer()
        }
        .sheet(isPresented: $isTrailerVisible) {
            if let trailerURL = trailerURL {
                SafariView(url: trailerURL)
            }
        }
    }
    
    private func loadTrailer() async {
        do {
            trailerURL =  try await movieService.getMoviesTrailer(movieId: movie.id)?.youtubeURL
        } catch {
            print("Failed to fetch video: \(error.localizedDescription)")
        }
    }
}

#Preview {
    NavigationStack {
        MovieDetailView(movie: Movie.mockMovies()[0])
    }
}
