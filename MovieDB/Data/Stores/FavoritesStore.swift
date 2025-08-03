//
//  FavoritesStore.swift
//  MovieDB
//
//  Created by Jhon Lopez on 7/25/25.
//

import Foundation
import Observation

@Observable
final class FavoritesStore  {
    // Set is more efficient than simple array as it eliminates duplicates and checking for existence is O(1)
    private(set) var favoriteMovieIDs: Set<Int> = []
    private let userDefaultKey = "favoriteMovieIDs"
    
    init() {
        if let savedIDs = UserDefaults.standard.array(forKey: userDefaultKey) as? [Int] {
            favoriteMovieIDs = Set(savedIDs)
        }
    }
    
    func isFavorite(movieId: Int) -> Bool {
        favoriteMovieIDs.contains(movieId)
    }
    
    func toggleFavorite(movieID: Int) {
        if isFavorite(movieId: movieID) {
            favoriteMovieIDs.remove(movieID)
        } else {
            favoriteMovieIDs.insert(movieID)
        }
        saveFavorites()
    }
    
    private func saveFavorites() {
        UserDefaults.standard.set(Array(favoriteMovieIDs), forKey: userDefaultKey)
    }
}
