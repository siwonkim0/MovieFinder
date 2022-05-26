//
//  NowPlayingMovieList.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/16.
//

import Foundation

// MARK: - MovieList
struct MovieList: Codable {
    let dates: Dates?
    let page: Int
    let results: [MovieListItem]
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

// MARK: - Dates
struct Dates: Codable {
    let maximum: String
    let minimum: String
}
