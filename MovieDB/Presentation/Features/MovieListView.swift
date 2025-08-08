//
//  MovieListView.swift
//  MovieDB
//
//  Created by Jhon Lopez on 7/25/25.
//

import SwiftUI

struct MovieListView: View {
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
//        .environment(MovieListViewModel())
}
