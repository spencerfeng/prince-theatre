//
//  MoviesServiceTests.swift
//  ldPrinceTheatreTests
//
//  Created by Spencer Feng on 9/10/21.
//

import XCTest
import Combine
@testable import ldPrinceTheatre

class MoviesServiceTests: XCTestCase {
    var sut: MoviesService!
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
        let session = URLSession(mockResponder: GetMoviesListSuccessfullyResponder.self)
        sut = MoviesService(session: session)
        
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
        
        XCTAssertEqual(result.count, 11)
        XCTAssertEqual(result[0].title, "Star Wars: Episode VII - The Force Awakens")
    }
    
    func testGetMoviesListFailedWithNetworkError() {
        let session = URLSession(mockResponder: GetMoviesListFailedResponder.self)
        sut = MoviesService(session: session)

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
        
        XCTAssertEqual(result!, .failure(APIError.network))
    }
    
    func testGetMoviesListFailedWithParsingError() {
        let session = URLSession(mockResponder: GetMoviesListBadGatewayResponder.self)
        sut = MoviesService(session: session)
        
        var result: Subscribers.Completion<APIError>?
        
        let receiveValueExpectation = self.expectation(description: "Awaiting receiving value")
        receiveValueExpectation.isInverted = true
        
        let receiveCompletionExpectation = self.expectation(description: "Awaiting receiving completion")
        
        sut
            .getMoviesList(provider: .filmworld)
            .sink(receiveCompletion: { comletion in
                receiveCompletionExpectation.fulfill()
                result = comletion
            }, receiveValue: { value in
                receiveValueExpectation.fulfill()
            })
            .store(in: &subscriptions)
        
        waitForExpectations(timeout: 0.3)
        
        XCTAssertEqual(result!, .failure(APIError.parsing))
    }
}

struct GetMoviesListSuccessfullyResponder: MockURLResponder {
    static func respond(to request: URLRequest) throws -> Data {
        return ResponseStubs.filmworldMoviesListSuccess.getResponseData()
    }
}

struct GetMoviesListFailedResponder: MockURLResponder {
    static func respond(to request: URLRequest) throws -> Data {
        throw MockError.random
    }
}

struct GetMoviesListBadGatewayResponder: MockURLResponder {
    static func respond(to request: URLRequest) throws -> Data {
        return ResponseStubs.filmworldMoviesListBadGateway.getResponseData()
    }
}

enum MockError: Error {
    case random
}


