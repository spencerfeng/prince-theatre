//
//  MoviesListViewModelTests.swift
//  ldPrinceTheatreTests
//
//  Created by Spencer Feng on 5/10/21.
//

import XCTest
import Combine
@testable import ldPrinceTheatre

class MoviesListViewModelTests: XCTestCase {
    var sut: MoviesListViewModel!
    var subscriptions = Set<AnyCancellable>()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        sut = nil
        subscriptions = []
        try super.tearDownWithError()
    }
    
    func testGetMoviesSuccessfully() {
        let mockConsolidatedMovie1 = ConsolidatedMovie(cinemaworldId: "cw1", filmworldId: "fw1", posterURL: "https://poster/cinemaworld/cw1", title: "Movie 1")
        let mockConsolidatedMovie2 = ConsolidatedMovie(cinemaworldId: "cw2", filmworldId: "fw2", posterURL: "https://poster/cinemaworld/cw2", title: "Movie 2")
        let mockMoivesRepository = MockMoviesRepository()
        mockMoivesRepository.moviesList = [mockConsolidatedMovie1, mockConsolidatedMovie2]
        sut = MoviesListViewModel(moviesRepository: mockMoivesRepository)
        
        XCTAssertEqual(sut.moviesList.count, 0)
        XCTAssertEqual(sut.viewState, .loading)
        
        sut.getMovies()
        
        XCTAssertEqual(sut.moviesList.count, 2)
        XCTAssertEqual(sut.moviesList[0].title, mockConsolidatedMovie1.title)
        XCTAssertEqual(sut.moviesList[1].title, mockConsolidatedMovie2.title)
        XCTAssertEqual(sut.viewState, .success)
    }
    
    func testGetMoviesFailed() {
        let mockMoviesRepository = MockMoviesRepository()
        mockMoviesRepository.shouldReturnGetMoviesListError = true
        sut = MoviesListViewModel(moviesRepository: mockMoviesRepository)
        
        XCTAssertEqual(sut.moviesList.count, 0)
        XCTAssertEqual(sut.viewState, .loading)
        
        sut.getMovies()
        
        XCTAssertEqual(sut.moviesList.count, 0)
        XCTAssertEqual(sut.viewState, .loadingFailed)
    }

}

private class MockMoviesRepository: MoviesRepository {
    var moviesList: [ConsolidatedMovie] = []
    var shouldReturnGetMoviesListError = false
    
    override func getMoviesList() -> AnyPublisher<[ConsolidatedMovie], AppError> {
        if !shouldReturnGetMoviesListError {
            return Just(moviesList).setFailureType(to: AppError.self).eraseToAnyPublisher()
        }
        return Fail<[ConsolidatedMovie], AppError>(error: .failedFetchMoviesList).eraseToAnyPublisher()
    }
}
