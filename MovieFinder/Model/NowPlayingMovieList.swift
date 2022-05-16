//
//  NowPlayingMovieList.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/16.
//

import Foundation
// MARK: - Welcome
struct NowPlayingMovieList: Codable {
    let dates: Dates
    let page: Int
    let results: [MovieListItem]
    let totalPages, totalResults: Int

    enum CodingKeys: String, CodingKey {
        case dates, page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

// MARK: - Dates
struct Dates: Codable {
    let maximum, minimum: String
}
