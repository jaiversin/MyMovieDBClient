//
//  MovieDetail.swift
//  MovieDB
//
//  Created by Jhon Lopez on 7/25/25.
//

import SwiftUI

struct MovieDetailView: View {
    let movie: Movie
    
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
    }
}

#Preview {
    NavigationStack {
        MovieDetailView(movie: Movie.mockMovies()[0])
    }
}
