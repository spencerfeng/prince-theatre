//
//  MovieDetailsViewModel.swift
//  ldPrinceTheatre
//
//  Created by Spencer Feng on 4/10/21.
//

import Foundation
import Combine

class MovieDetailsViewModel {
    
    @Published var lowPriceProvider: String = ""
    @Published var lowPriceAmount: String = ""
    @Published var highPriceProvider: String = ""
    @Published var highPriceAmount: String = ""
    @Published var loadingPricesState: ViewState = .loading
    
    private let moviesRepository: MoviesRepository
    private let movie: ConsolidatedMovie
    
    private var subscriptions = Set<AnyCancellable>()
    
    init(moviesRepository: MoviesRepository, movie: ConsolidatedMovie) {
        self.moviesRepository = moviesRepository
        self.movie = movie
    }
    
    func getMovieDetails() {
        loadingPricesState = .loading
        moviesRepository
            .getMovieDetails(movie: movie)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let err) = completion {
                    print("sink completion with error in MovieDetailsViewModel: \(err)")
                    self?.loadingPricesState = .loadingFailed
                }
            }, receiveValue: { [weak self] movieDetails in
                if (movieDetails.cinemaworldPrice >= movieDetails.filmworldPrice) {
                    self?.lowPriceProvider = "Filmworld: "
                    self?.lowPriceAmount = "$\(movieDetails.filmworldPrice)"
                    self?.highPriceProvider = "Cinemaworld: "
                    self?.highPriceAmount = "$\(movieDetails.cinemaworldPrice)"
                } else {
                    self?.lowPriceProvider = "Cinemaworld: "
                    self?.lowPriceAmount = "$\(movieDetails.cinemaworldPrice)"
                    self?.highPriceProvider = "Filmworld: "
                    self?.highPriceAmount = "$\(movieDetails.filmworldPrice)"
                }
                
                self?.loadingPricesState = .success
            })
            .store(in: &subscriptions)
    }
    
    func getMovieTitle() -> String {
        return movie.title
    }
    
    func getMoviePosterURL() -> String {
        return movie.posterURL
    }
}
