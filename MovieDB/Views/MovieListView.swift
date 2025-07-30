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
