//
//  MovieDetails.swift
//  ldPrinceTheatre
//
//  Created by Spencer Feng on 3/10/21.
//

import Foundation

struct RawMovieDetails: Decodable {
    let price: Double
    
    enum CodingKeys: String, CodingKey {
        case price = "Price"
    }
}

struct ConsolidatedMovieDetails {
    let consolidatedMovie: ConsolidatedMovie
    let cinemaworldPrice: Double
    let filmworldPrice: Double
}
