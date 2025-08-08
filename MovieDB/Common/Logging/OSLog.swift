//
//  OSLog.swift
//  MovieDB
//
//  Created by Jhon Lopez on 8/6/25.
//

import OSLog

extension Logger {
    static let subsystem = Bundle.main.bundleIdentifier ?? "com.jhonlopez.moviedb"
    static let movieDB = Logger(subsystem: subsystem, category: "MovieDB")
}

extension OSLog {
    static let dataFetchSignpost = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "com.jhonlopez.moviedb", category: "DataFetching")
    static let pointsOfInterest = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "com.jhonlopez.moviedb", category: .pointsOfInterest)
}

