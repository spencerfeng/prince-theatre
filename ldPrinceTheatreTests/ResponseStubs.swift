//
//  ResponseStubs.swift
//  ldPrinceTheatreTests
//
//  Created by Spencer Feng on 10/10/21.
//

import Foundation
@testable import ldPrinceTheatre

enum ResponseStubs: String {
    case filmworldMoviesListSuccess = "filmworld_movies_list_success"
    case filmworldMoviesListBadGateway = "filmworld_movies_list_bad_gateway"
    
    func getResponseData() -> Data {
        return TestHelper().loadDataFromJson(fileName: self.rawValue)
    }
}
