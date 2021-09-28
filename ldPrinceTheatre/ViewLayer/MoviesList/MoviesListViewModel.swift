//
//  MoviesListViewModel.swift
//  ldPrinceTheatre
//
//  Created by Spencer Feng on 2/10/21.
//

import Foundation
import Combine

class MoviesListViewModel {
    @Published var moviesList: [ConsolidatedMovie] = []
    @Published var viewState: ViewState = .loading
    
    private let moviesRepository: MoviesRepository
    private var subscriptions = Set<AnyCancellable>()
    
    init(moviesRepository: MoviesRepository) {
        self.moviesRepository = moviesRepository
    }
    
    func getMovies() {
        viewState = .loading
        moviesRepository
            .getMoviesList()
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let err) = completion {
                    print("sink completion with error in MoviesListViewModel: \(err)")
                    self?.viewState = .loadingFailed
                }
            }, receiveValue: { [weak self] value in
                self?.moviesList = value
                self?.viewState = .success
            })
            .store(in: &subscriptions)
    }
    
    func buildMovieDetailsViewModel(movie: ConsolidatedMovie) -> MovieDetailsViewModel {
        return MovieDetailsViewModel(moviesRepository: moviesRepository, movie: movie)
    }
}
