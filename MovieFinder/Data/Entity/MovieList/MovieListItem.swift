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
    let originalTitle: String
    let overview: String
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

extension MovieListItem {
    func convertToModel() -> ListItem {
        return ListItem(id: self.id,
                        title: self.title,
                        overview: self.overview,
                        releaseDate: self.releaseDate,
                        posterPath: self.posterPath,
                        rating: self.rating,
                        originalLanguage: self.originalLanguage
        )
    }
}
