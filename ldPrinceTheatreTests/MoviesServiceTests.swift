//
//  MoviesServiceTests.swift
//  ldPrinceTheatreTests
//
//  Created by Spencer Feng on 9/10/21.
//

import XCTest
import Combine
import Alamofire
import Mocker
@testable import ldPrinceTheatre

class MoviesServiceTests: XCTestCase {
    var sut: MoviesService!
    var subscriptions = Set<AnyCancellable>()
    var sessionManager: Session!

    override func setUpWithError() throws {
        let configuration = URLSessionConfiguration.af.default
        configuration.protocolClasses = [MockingURLProtocol.self]
        sessionManager = Alamofire.Session(configuration: configuration)
    }

    override func tearDownWithError() throws {
        sut = nil
        subscriptions = []
        try super.tearDownWithError()
    }

    func testGetMoviesListSuccessfully() {
        let originalURL = URL(string: "https://challenge.lexicondigital.com.au/api/filmworld/movies")!
        let mock = Mock(url: originalURL, dataType: .json, statusCode: 200, data: [
            .get : ResponseStubs.filmworldMoviesListSuccess.getResponseData()
        ])
        mock.register()
        
        sut = MoviesService(session: sessionManager)
        
        var result: [RawMovie] = []
        
        let expectation = self.expectation(description: "Awaiting getting movies list")
        
        sut
            .getMoviesList(provider: .filmworld)
            .sink(receiveCompletion: { _ in
                expectation.fulfill()
            }, receiveValue: { value in
                result.append(contentsOf: value)
            })
            .store(in: &subscriptions)
        
        waitForExpectations(timeout: 10)
        
        XCTAssertEqual(result.count, 10)
        XCTAssertEqual(result[0].title, "Star Wars: Episode VII - The Force Awakens Again")
    }
    
    func testGetMoviesListFailedWithError() {
        let originalURL = URL(string: "https://challenge.lexicondigital.com.au/api/filmworld/movies")!
        let mock = Mock(url: originalURL, dataType: .json, statusCode: 500, data: [.get: Data()], requestError: APIError.networking)
        mock.register()
        
        sut = MoviesService(session: sessionManager)

        var result: Subscribers.Completion<APIError>?

        let receiveValueExpectation = self.expectation(description: "Awaiting receiving value")
        receiveValueExpectation.isInverted = true

        let receiveCompletionExpectation = self.expectation(description: "Awaiting receiving completion")

        sut
            .getMoviesList(provider: .filmworld)
            .sink(receiveCompletion: { completion in
                receiveCompletionExpectation.fulfill()
                result = completion
            }, receiveValue: { value in
                receiveValueExpectation.fulfill()
            })
            .store(in: &subscriptions)

        waitForExpectations(timeout: 0.3)

        XCTAssertEqual(result!, .failure(APIError.networking))
    }
    
    func testGetMovieDetailsSuccessfully() {
        let originalURL = URL(string: "https://challenge.lexicondigital.com.au/api/filmworld/movie/fw2488496")!
        let mock = Mock(url: originalURL, dataType: .json, statusCode: 200, data: [
            .get : ResponseStubs.filmworldMovieDetailsSuccess.getResponseData()
        ])
        mock.register()
        
        sut = MoviesService(session: sessionManager)
        
        let receiveCompletionExpectation = self.expectation(description: "Awaiting receiving completion")
        
        var result: RawMovieDetails?
        
        sut
            .getMovie(provider: .filmworld, movieId: "fw2488496")
            .sink(receiveCompletion: { completion in
                receiveCompletionExpectation.fulfill()
            }, receiveValue: { value in
                result = value
            })
            .store(in: &subscriptions)
        
        waitForExpectations(timeout: 0.3)
        
        XCTAssertEqual(result!.price, 29.5)
    }
    
    func testGetMovieDetailsFailedWithError() {
        let originalURL = URL(string: "https://challenge.lexicondigital.com.au/api/filmworld/movie/fw2488496")!
        let mock = Mock(url: originalURL, dataType: .json, statusCode: 502, data: [.get: Data()])
        mock.register()

        sut = MoviesService(session: sessionManager)
        
        let receiveCompletionExpectation = self.expectation(description: "Awaiting receiving completion")
        let receiveValueExpectation = self.expectation(description: "Awaiting receiving value")
        receiveValueExpectation.isInverted = true
        
        var result: Subscribers.Completion<APIError>?
        
        sut
            .getMovie(provider: .filmworld, movieId: "fw2488496")
            .sink(receiveCompletion: { completion in
                receiveCompletionExpectation.fulfill()
                result = completion
            }, receiveValue: { value in
                receiveValueExpectation.fulfill()
            })
            .store(in: &subscriptions)
        
        waitForExpectations(timeout: 0.3)
        
        XCTAssertEqual(result!, .failure(APIError.networking))
    }
}



