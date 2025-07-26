//
//  MovieService.swift
//  MovieDB
//
//  Created by Jhon Lopez on 7/24/25.
//
import Foundation
import Combine

enum MovieConstants {
    static var posterBaseURL = URL(string: "https://image.tmdb.org/t/p/w500")
    static var apiKey = "2ee31abe59dffcca50f2c2876a0a3899"
    static var baseURL = URL(string: "https://api.themoviedb.org/3")!
}

final class MovieService {
    static var shared = MovieService()
    

    private lazy var jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.httpAdditionalHeaders = ["Content-Type": "application/json"]
        return URLSession(configuration: configuration)
    }()
    
    // MARK: - Async/Await
    
    func fetchPopularMovies() async throws -> [Movie] {
        // Build the URL
//        guard let url = URL(string: "\(baseURL)/movie/popular?api_key=\(apiKey)") else { throw URLError(.badURL) }
        
        let url = MovieConstants.baseURL
                    .appending(path: "/movie/popular")
                    .appending(queryItems: [URLQueryItem(name: "api_key", value: MovieConstants.apiKey)])
        
        // Fetch data and response info
        let (responseData, response) = try await session.data(for: URLRequest(url: url))
        
        // If response was successful
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            // If not successful, throw an error. This can be improved by defining our own errors but by now we can leave it generic
            throw URLError(.badServerResponse)
        }
        
        do {
            let movies = try jsonDecoder.decode(MovieResponse.self, from: responseData)
            return movies.results
        }
        catch {
            print("Failed to decode: \(error)")
            throw error
        }
    }
    
    func getMoviesTrailer(movieId: Int) async throws -> Video? {
        let url = MovieConstants.baseURL
            .appending(path: "/movie/\(movieId)/videos")
            .appending(queryItems: [URLQueryItem(name: "api_key", value: MovieConstants.apiKey)])
            .appending(queryItems: [URLQueryItem(name: "language", value: "en-US")])
        
        let (responseData, response) = try await session.data(from: url)
        
        // If response was successful
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            // If not successful, throw an error. This can be improved by defining our own errors but by now we can leave it generic
            throw URLError(.badServerResponse)
        }
        
        do {
            let movies = try jsonDecoder.decode(VideoResponse.self, from: responseData)
            
            return movies.results.filter { $0.isTrailerOnYoutube }.first
        }
        catch {
            print("Failed to decode: \(error)")
            throw error
        }
    }
    
    // MARK: - Combine
    
    /// This function should be used when a more dynamic/reactive use case is needed. For a one shot request like this list, it's better (for readability) to use async await mechanism.
    func fetchPopularMoviesPublisher() -> AnyPublisher<[Movie], Error> {
//        guard let url = URL(string: "\(baseURL)/movie/popular?api_key=\(apiKey)") else {
//            return Fail(error: URLError(.badURL))
//                .eraseToAnyPublisher()
//        }
        let url = MovieConstants.baseURL
                    .appending(path: "/movie/popular")
                    .appending(queryItems: [URLQueryItem(name: "api_key", value: MovieConstants.apiKey)])
        
        let request = URLRequest(url: url)
        
        return session.dataTaskPublisher(for: request)
            .tryMap({ data, response in
                guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                    throw URLError(.badServerResponse)
                }
                return data
            })
            .decode(type: MovieResponse.self, decoder: jsonDecoder)
            .map(\.results)
            .eraseToAnyPublisher()
    }
}
