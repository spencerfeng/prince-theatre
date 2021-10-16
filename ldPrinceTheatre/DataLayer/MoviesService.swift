//
//  MoviesService.swift
//  ldPrinceTheatre
//
//  Created by Spencer Feng on 28/9/21.
//

import Foundation
import Combine
import UIKit
import Alamofire

enum APIError: Error {
    case invalidResponseValue
    case networking
}

class MoviesService {
    
    private let session: Session

    private let headers: HTTPHeaders = [
        "x-api-key": "Yr2636E6BTD3UCdleMkf7UEdqKnd9n361TQL9An7"
    ]
    private let apiBaseURL = "https://challenge.lexicondigital.com.au/api"
    
    init(session: Session = AF) {
        self.session = session
    }
    
    func getMoviesList(provider: MovieProvider) -> AnyPublisher<[RawMovie], APIError> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            
            self.session.request(self.buildGetMoviesListURLString(provider: provider), headers: self.headers)
                .validate()
                .responseDecodable(of: RawMoviesList.self) { response in
                    switch response.result {
                    case .success:
                        guard let value = response.value else {
                            return promise(.failure(APIError.invalidResponseValue))
                        }
                        return promise(.success(value.movies))
                    case .failure(let error):
                        print("AF error in getting movies list: \(error)")
                        return promise(.failure(APIError.networking))
                    }
                }
        }
        .eraseToAnyPublisher()
    }
    
    func getMovie(provider: MovieProvider, movieId: String) -> AnyPublisher<RawMovieDetails, APIError> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            
            self.session.request(self.buildGetMovieDetailsURLString(provider: provider, movieId: movieId), headers: self.headers)
                .validate()
                .responseDecodable(of: RawMovieDetails.self) { response in
                    switch response.result {
                    case .success:
                        guard let value = response.value else { return promise(.failure(APIError.invalidResponseValue))}
                        return promise(.success(value))
                    case .failure(let error):
                        print("AF error in getting movie details: \(error)")
                        return promise(.failure(APIError.networking))
                    }
                }
        }
        .eraseToAnyPublisher()
    }
    
    private func buildGetMoviesListURLString(provider: MovieProvider) -> String {
        switch provider {
        case .cinemaworld:
            return "\(apiBaseURL)/cinemaworld/movies"
        case .filmworld:
            return "\(apiBaseURL)/filmworld/movies"
        }
    }
    
    private func buildGetMovieDetailsURLString(provider: MovieProvider, movieId: String) -> String {
        switch provider {
        case .cinemaworld:
            return "\(apiBaseURL)/cinemaworld/movie/\(movieId)"
        case .filmworld:
            return "\(apiBaseURL)/filmworld/movie/\(movieId)"
        }
    }
    
}

