//
//  SwiftDataStore.swift
//  MovieDB
//
//  Created by Jhon Lopez on 8/2/25.
//

import Foundation
import SwiftData

@Model
final class PersistentMovie {
    @Attribute(.unique) var id: Int
    var overview: String
    var title: String
    var posterPath: String?
    var releaseDate: String?
    var voteAverage: Double

    init(id: Int, overview: String, title: String, posterPath: String?, releaseDate: String?, voteAverage: Double) {
        self.id = id
        self.overview = overview
        self.title = title
        self.posterPath = posterPath
        self.releaseDate = releaseDate
        self.voteAverage = voteAverage
    }
}

struct MovieMapper {
    static func toPersistent(model: Movie) -> PersistentMovie {
        .init(id: model.id,
              overview: model.overview,
              title: model.title,
              posterPath: model.posterPath,
              releaseDate: model.releaseDate,
              voteAverage: model.voteAverage)
    }
    
    static func toDomain(model: PersistentMovie) -> Movie {
        .init(id: model.id,
              overview: model.overview,
              title: model.title,
              posterPath: model.posterPath,
              releaseDate: model.releaseDate,
              voteAverage: model.voteAverage)
    }
}
