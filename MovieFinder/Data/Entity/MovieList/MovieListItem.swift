//
//  MovieListItem.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/16.
//

import Foundation

// MARK: - MovieListItem
struct MovieListItem: Codable {
    let adult: Bool
    let backdropPath: String?
    let genreIDS: [Int]
    let id: Int
    let originalLanguage: String
    let originalTitle, overview: String
    let popularity: Double
    let posterPath: String?
    let releaseDate: String?
    let title: String
    let video: Bool
    let voteAverage: Double
    let voteCount: Int
    let rating: Double?

    enum CodingKeys: String, CodingKey {
        case adult
        case backdropPath = "backdrop_path"
        case genreIDS = "genre_ids"
        case id
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case overview, popularity
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case title, video
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case rating
    }
}

//enum OriginalLanguage: String, Codable {
//    case en = "en"
//    case tr = "tr"
//    case es = "es"
//    case fr = "fr"
//    case la = "la"
//    case hi = "hi"
//    case ja = "ja"
//    case ko = "ko"
//    case th = "th"
//    case it = "it"
//    case fi = "fi"
//    case da = "da"
//}
