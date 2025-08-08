//
//  TestData.swift
//  MovieDB
//
//  Created by Jhon Lopez on 8/8/25.
//

@testable import MovieDB

struct TestData {
    static let movie1 = Movie(
            id: 1,
            overview: "Test Overview 1",
            title: "Test Movie 1",
            posterPath: "/test1.jpg",
            releaseDate: "2025-08-08",
            voteAverage: 10.0
        )
    
    static let movie2 = Movie(
            id: 2,
            overview: "Test Overview 2",
            title: "Test Movie 2",
            posterPath: "/test2.jpg",
            releaseDate: "2025-05-08",
            voteAverage: 6.0
        )
    
    static let movie3 = Movie(
            id: 3,
            overview: "Test Overview 3",
            title: "Test Movie 3",
            posterPath: "/test3.jpg",
            releaseDate: "2025-02-08",
            voteAverage: 7.0
        )
}
