//
//  MovieCardView.swift
//  MovieDB
//
//  Created by Jhon Lopez on 7/25/25.
//
import SwiftUI

struct MovieCardView: View {
    let movie: Movie
    var body: some View {
        VStack(alignment: .center, spacing: 5) {
            AsyncImage(url: movie.posterPathURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(10)
            } placeholder: {
                Rectangle()
                    .foregroundStyle(.gray.opacity(0.1))
                    .aspectRatio(2/3, contentMode: .fit)
                    .cornerRadius(10)
                    .overlay {
                        ProgressView()
                    }
            }
            Spacer()
            VStack(spacing: 0) {
                Text(movie.title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.black)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                if let releaseDate = movie.releaseDate {
                    Text(releaseDate)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .foregroundStyle(.gray)
                }
                // create a starts base rating usinge voteAverage
                HStack(alignment: .top, spacing: 2) {
                    ForEach(0..<Int(movie.voteAverage / 2), id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 8))
                    }
                }
                .font(.caption2)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

#Preview {
    MovieCardView(movie: Movie.mockMovies()[0])
}
