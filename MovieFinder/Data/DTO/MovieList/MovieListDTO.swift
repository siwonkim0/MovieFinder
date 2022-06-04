//
//  NowPlayingMovieList.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/16.
//

import Foundation

// MARK: - MovieListDTO
struct MovieListDTO: Codable {
    let dates: DatesDTO?
    let page: Int
    let results: [MovieListItemDTO]
    let totalPages: Int
    let totalResults: Int

    enum CodingKeys: String, CodingKey {
        case dates
        case page
        case results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

// MARK: - DatesDTO
struct DatesDTO: Codable {
    let maximum: String
    let minimum: String
}
