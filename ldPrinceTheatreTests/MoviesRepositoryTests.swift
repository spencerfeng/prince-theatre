//
//  MoviesRepositoryTests.swift
//  ldPrinceTheatreTests
//
//  Created by Spencer Feng on 7/10/21.
//

import XCTest
import Combine
@testable import ldPrinceTheatre

class MoviesRepositoryTests: XCTestCase {
    var sut: MoviesRepository!
    var subscriptions = Set<AnyCancellable>()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        sut = nil
        subscriptions = []
        try super.tearDownWithError()
    }
    
    func testGetMoviesListSuccessfully() {
        let mockFilmworldRawMovies = [RawMovie(id: "fw1", title: "Movie 1", posterURL: "https://url1"), RawMovie(id: "fw2", title: "Movie 2", posterURL: "https://url2")]
        let mockCinemaworldRawMovies = [RawMovie(id: "cw1", title: "Movie 1", posterURL: "https://url1"), RawMovie(id: "cw2", title: "Movie 2", posterURL: "https://url2")]
        let mockMoviesService = MockMoviesService()
        mockMoviesService.filmworldRawMovies = mockFilmworldRawMovies
        mockMoviesService.cinemaworldRawMovies = mockCinemaworldRawMovies
        sut = MoviesRepository(moviesService: mockMoviesService)
        
        let expectation = self.expectation(description: "Awaiting getting movies list")
        
        var result: [ConsolidatedMovie] = []
        
        sut
            .getMoviesList()
            .sink(receiveCompletion: { _ in
                expectation.fulfill()
            }, receiveValue: { value in
                result.append(contentsOf: value)
            })
            .store(in: &subscriptions)
        
        waitForExpectations(timeout: 10)
        
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].title, "Movie 1")
        XCTAssertEqual(result[0].filmworldId, "fw1")
        XCTAssertEqual(result[0].cinemaworldId, "cw1")
        XCTAssertEqual(result[1].title, "Movie 2")
        XCTAssertEqual(result[1].filmworldId, "fw2")
        XCTAssertEqual(result[1].cinemaworldId, "cw2")
    }
    
    func testGetMoviesListWillFailIfOneMoviesServiceFails() {
        let mockFilmworldRawMovies = [RawMovie(id: "fw1", title: "Movie 1", posterURL: "https://url1"), RawMovie(id: "fw2", title: "Movie 2", posterURL: "https://url2")]
        let mockMoviesService = MockMoviesService()
        mockMoviesService.filmworldRawMovies = mockFilmworldRawMovies
        mockMoviesService.shouldReturnErrorForCinemaworldMoviesList = true
        
        let receiveCompletionExpectation = expectation(description: "Awaiting receiving completion")
        
        let receiveValueExpectation = expectation(description: "Awaiting receiving value")
        receiveValueExpectation.isInverted = true
        
        sut = MoviesRepository(moviesService: mockMoviesService)
        
        sut
            .getMoviesList()
            .sink(receiveCompletion: { completion in
                receiveCompletionExpectation.fulfill()
                XCTAssertEqual(completion, .failure(AppError.failedFetchMoviesList))
            }, receiveValue: { value in
                receiveValueExpectation.fulfill()
            })
            .store(in: &subscriptions)
        
        waitForExpectations(timeout: 0.3)
    }
    
    func testGetMoviesListWillFailIFBothMoviesServiceFail() {
        let mockMoivesService = MockMoviesService()
        mockMoivesService.shouldReturnErrorForCinemaworldMoviesList = true
        mockMoivesService.shouldReturnErrorForFilmworldMoviesList = true
        sut = MoviesRepository(moviesService: mockMoivesService)
        
        let receiveCompletionExpectation = self.expectation(description: "Awaiting receiving completion")
        
        let receiveValueExpectation = self.expectation(description: "Awaiting receiving value")
        receiveValueExpectation.isInverted = true
        
        sut
            .getMoviesList()
            .sink(receiveCompletion: { completion in
                receiveCompletionExpectation.fulfill()
                XCTAssertEqual(completion, .failure(AppError.failedFetchMoviesList))
            }, receiveValue: { value in
                receiveValueExpectation.fulfill()
            })
            .store(in: &subscriptions)
        
        waitForExpectations(timeout: 0.3)
    }
    
    func testGetMovieDetailsSuccessfully() {
        let mockFilmworldRawMovieDetails = RawMovieDetails(price: 2.8)
        let mockCinemaworldRawMovieDetails = RawMovieDetails(price: 2.6)
        let mockMoviesService = MockMoviesService()
        mockMoviesService.filmworldRawMovieDetails = mockFilmworldRawMovieDetails
        mockMoviesService.cinemaworldRawMovieDetails = mockCinemaworldRawMovieDetails
        let mockConsolidatedMovie = ConsolidatedMovie(cinemaworldId: "cw1", filmworldId: "fw1", posterURL: "https://url1", title: "Movie 1")
        sut = MoviesRepository(moviesService: mockMoviesService)
        
        let expectation = self.expectation(description: "Awaiting receiving completion")
        
        var result: ConsolidatedMovieDetails?
        
        sut
            .getMovieDetails(movie: mockConsolidatedMovie)
            .sink(receiveCompletion: { completion in
                expectation.fulfill()
            }, receiveValue: { value in
                result = value
            })
            .store(in: &subscriptions)
        
        waitForExpectations(timeout: 0.3)
        
        XCTAssertEqual(result!.cinemaworldPrice, 2.6)
        XCTAssertEqual(result!.filmworldPrice, 2.8)
    }
    
    func testGetMovieDetailsWillFailIfOneMoviesServiceFails() {
        let mockFilmworldRawMovieDetails = RawMovieDetails(price: 2.8)
        let mockMoviesService = MockMoviesService()
        mockMoviesService.filmworldRawMovieDetails = mockFilmworldRawMovieDetails
        mockMoviesService.shouldReturnErrorForCinemaworldMovieDetails = true
        let mockConsolidatedMovie = ConsolidatedMovie(cinemaworldId: "cw1", filmworldId: "fw1", posterURL: "https://url1", title: "Movie 1")
        sut = MoviesRepository(moviesService: mockMoviesService)
        
        var result: Subscribers.Completion<AppError>?
        
        let expectation = self.expectation(description: "Awaiting receiving value")
        expectation.isInverted = true
        
        sut
            .getMovieDetails(movie: mockConsolidatedMovie)
            .sink(receiveCompletion: { completion in
                result = completion
            }, receiveValue: { value in
                expectation.fulfill()
            })
            .store(in: &subscriptions)
        
        waitForExpectations(timeout: 0.3)
        
        XCTAssertEqual(result!, .failure(AppError.failedFetchMovieDetails))
    }
    
    func testGetMovieDetailsWillFailIfBothMoviesServiceFail() {
        let mockMoviesService = MockMoviesService()
        mockMoviesService.shouldReturnErrorForCinemaworldMovieDetails = true
        mockMoviesService.shouldReturnErrorForFilmworldMovieDetails = true
        let mockConsolidatedMovie = ConsolidatedMovie(cinemaworldId: "cw1", filmworldId: "fw1", posterURL: "https://url1", title: "Movie 1")
        sut = MoviesRepository(moviesService: mockMoviesService)
        
        var result: Subscribers.Completion<AppError>?
        
        let expectation = self.expectation(description: "Awaiting receiving value")
        expectation.isInverted = true
        
        sut
            .getMovieDetails(movie: mockConsolidatedMovie)
            .sink(receiveCompletion: { completion in
                result = completion
            }, receiveValue: { value in
                expectation.fulfill()
            })
            .store(in: &subscriptions)
        
        waitForExpectations(timeout: 0.3)
        
        XCTAssertEqual(result!, .failure(AppError.failedFetchMovieDetails))
    }

}

private class MockMoviesService: MoviesService {
    
    var filmworldRawMovies: [RawMovie] = []
    var cinemaworldRawMovies: [RawMovie] = []
    var shouldReturnErrorForFilmworldMoviesList = false
    var shouldReturnErrorForCinemaworldMoviesList = false
    
    override func getMoviesList(provider: MovieProvider) -> AnyPublisher<[RawMovie], APIError> {
        if provider == .filmworld {
            if !shouldReturnErrorForFilmworldMoviesList {
                return Just(filmworldRawMovies).setFailureType(to: APIError.self).eraseToAnyPublisher()
            }
            return Fail<[RawMovie], APIError>(error: .networking).eraseToAnyPublisher()
        }
        
        if !shouldReturnErrorForCinemaworldMoviesList {
            return Just(cinemaworldRawMovies).setFailureType(to: APIError.self).eraseToAnyPublisher()
        }
        return Fail<[RawMovie], APIError>(error: .networking).eraseToAnyPublisher()
    }
    
    var filmworldRawMovieDetails: RawMovieDetails?
    var cinemaworldRawMovieDetails: RawMovieDetails?
    var shouldReturnErrorForFilmworldMovieDetails = false
    var shouldReturnErrorForCinemaworldMovieDetails = false
    
    override func getMovie(provider: MovieProvider, movieId: String) -> AnyPublisher<RawMovieDetails, APIError> {
        if provider == .filmworld {
            if !shouldReturnErrorForFilmworldMovieDetails {
                return Just(filmworldRawMovieDetails!).setFailureType(to: APIError.self).eraseToAnyPublisher()
            }
            return Fail<RawMovieDetails, APIError>(error: APIError.networking).eraseToAnyPublisher()
        }
        
        if !shouldReturnErrorForCinemaworldMovieDetails {
            return Just(cinemaworldRawMovieDetails!).setFailureType(to: APIError.self).eraseToAnyPublisher()
        }
        return Fail<RawMovieDetails, APIError>(error: APIError.networking).eraseToAnyPublisher()
    }
    
}
