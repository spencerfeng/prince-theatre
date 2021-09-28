//
//  Movie.swift
//  ldPrinceTheatre
//
//  Created by Spencer Feng on 28/9/21.
//

import Foundation

enum MovieType: String, Decodable {
    case movie
}

enum MovieProvider: String, Decodable {
    case cinemaworld = "Cinema World"
    case filmworld = "Film World"
}

struct RawMovie: Decodable {
    let id: String
    let title: String
    let posterURL: String
    
    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case title = "Title"
        case posterURL = "Poster"
    }
}

struct RawMoviesList: Decodable {
    let provider: String
    let movies: [RawMovie]
    
    enum CodingKeys: String, CodingKey {
        case provider = "Provider"
        case movies = "Movies"
    }
}

struct ConsolidatedMovie {
    let cinemaworldId: String
    let filmworldId: String
    let posterURL: String
    let title: String
}
