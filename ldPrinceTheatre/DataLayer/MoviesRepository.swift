//
//  MoviesRepository.swift
//  ldPrinceTheatre
//
//  Created by Spencer Feng on 28/9/21.
//

import Foundation
import Combine

enum AppError: Error {
    case failedFetchMoviesList
    case failedFetchMovieDetails
}

protocol MoviesRepositoryProtocol {
    func getMoviesList() -> AnyPublisher<[ConsolidatedMovie], AppError>
    func getMovieDetails(movie: ConsolidatedMovie) -> AnyPublisher<ConsolidatedMovieDetails, AppError>
}

class MoviesRepository: MoviesRepositoryProtocol {
    
    private let moviesService: MoviesService
    
    init(moviesService: MoviesService = MoviesService()) {
        self.moviesService = moviesService
    }
    
    func getMoviesList() -> AnyPublisher<[ConsolidatedMovie], AppError> {
        let getCinemaworldMoviesPublisher = moviesService.getMoviesList(provider: .cinemaworld)
        let getFilmworldMoviesPublisher = moviesService.getMoviesList(provider: .filmworld)
        
        return Publishers
                .Zip(getCinemaworldMoviesPublisher, getFilmworldMoviesPublisher)
                .map { (result: ([RawMovie], [RawMovie])) -> [ConsolidatedMovie] in
                    let cinemaworldMovies = result.0
                    let filmworldMovies = result.1
                    
                    return cinemaworldMovies.compactMap { cinemaworldMovie in
                        let filmworldMovieWithTheSameTitle = filmworldMovies.first(where: { $0.title == cinemaworldMovie.title })
                        guard let filmworldMovie = filmworldMovieWithTheSameTitle else { return nil }
                        return ConsolidatedMovie(cinemaworldId: cinemaworldMovie.id, filmworldId: filmworldMovie.id, posterURL:cinemaworldMovie.posterURL, title: cinemaworldMovie.title)
                    }
                }
                .mapError { _ -> AppError in
                    return .failedFetchMoviesList
                }
                .eraseToAnyPublisher()
    }
    
    func getMovieDetails(movie: ConsolidatedMovie) -> AnyPublisher<ConsolidatedMovieDetails, AppError> {
        let getCinemaworldMovieDetailsPublisher = moviesService.getMovie(provider: .cinemaworld, movieId: movie.cinemaworldId)
        let getFilmworldMovieDetailsPublisher = moviesService.getMovie(provider: .filmworld, movieId: movie.filmworldId)
        
        return Publishers
            .Zip(getCinemaworldMovieDetailsPublisher, getFilmworldMovieDetailsPublisher)
            .map { (result: (RawMovieDetails, RawMovieDetails)) -> ConsolidatedMovieDetails in
                let cinemaworldMovieDetails = result.0
                let filmworldMovieDetails = result.1
                
                return ConsolidatedMovieDetails(consolidatedMovie: movie, cinemaworldPrice: cinemaworldMovieDetails.price, filmworldPrice: filmworldMovieDetails.price)
            }
            .mapError { _ -> AppError in
                return .failedFetchMovieDetails
            }
            .eraseToAnyPublisher()
    }
    
}
