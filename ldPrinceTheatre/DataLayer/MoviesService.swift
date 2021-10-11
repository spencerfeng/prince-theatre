//
//  MoviesService.swift
//  ldPrinceTheatre
//
//  Created by Spencer Feng on 28/9/21.
//

import Foundation
import Combine
import UIKit

enum APIError: Error {
    case url
    case network
    case parsing
    case unknown
}

class MoviesService {
    
    private let session: URLSession
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    func getMoviesList(provider: MovieProvider) -> AnyPublisher<[RawMovie], APIError> {
        guard let url = buildGetMoivesListURL(provider: provider) else {
            return Fail<[RawMovie], APIError>(error: .url).eraseToAnyPublisher()
        }
        
        return session
            .dataTaskPublisher(for: buildRequest(url: url))
            .map(\.data)
            .decode(type: RawMoviesList.self, decoder: JSONDecoder())
            .map { $0.movies }
            .mapError { error -> APIError in
                switch error {
                case is URLError:
                    return .network
                case is DecodingError:
                    return .parsing
                default:
                    return .unknown
                }
            }
            .eraseToAnyPublisher()
    }
    
    func getMovie(provider: MovieProvider, movieId: String) -> AnyPublisher<RawMovieDetails, APIError> {
        guard let url = buildGetMovieDetailsURL(provider: provider, movieId: movieId) else {
            return Fail<RawMovieDetails, APIError>(error: .url).eraseToAnyPublisher()
        }
        
        return session
            .dataTaskPublisher(for: buildRequest(url: url))
            .map(\.data)
            .decode(type: RawMovieDetails.self, decoder: JSONDecoder())
            .mapError { error -> APIError in
                switch error {
                case is URLError:
                    return .network
                case is DecodingError:
                    return .parsing
                default:
                    return .unknown
                }
            }
            .eraseToAnyPublisher()
    }
    
    private func buildGetMoivesListURL(provider: MovieProvider) -> URL? {
        switch provider {
        case .cinemaworld:
            return URL(string: "https://challenge.lexicondigital.com.au/api/cinemaworld/movies")
        case .filmworld:
            return URL(string: "https://challenge.lexicondigital.com.au/api/filmworld/movies")
        }
    }
    
    private func buildGetMovieDetailsURL(provider: MovieProvider, movieId: String) -> URL? {
        switch provider {
        case .cinemaworld:
            return URL(string: "https://challenge.lexicondigital.com.au/api/cinemaworld/movie/\(movieId)")
        case .filmworld:
            return URL(string: "https://challenge.lexicondigital.com.au/api/filmworld/movie/\(movieId)")
        }
    }
    
    private func buildRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.setValue("Yr2636E6BTD3UCdleMkf7UEdqKnd9n361TQL9An7", forHTTPHeaderField: "x-api-key")
        return request
    }
    
}

