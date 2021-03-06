//
//  OMDBMovieDetail.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/17.
//

import Foundation

// MARK: - OMDBMovieDetailDTO
struct OMDBMovieDetailDTO: Codable {
    let title: String
    let year: String
    let rated: String
    let released: String
    let runtime: String
    let genre: String
    let director: String
    let writer: String
    let actors: String
    let plot: String
    let language: String
    let country: String
    let awards: String
    let poster: String
    let ratings: [RatingDTO]
    let metascore: String
    let imdbRating: String
    let imdbVotes: String
    let imdbID: String
    let type: String
    let dvd: String
    let boxOffice: String
    let production: String
    let website: String
    let response: String

    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case year = "Year"
        case rated = "Rated"
        case released = "Released"
        case runtime = "Runtime"
        case genre = "Genre"
        case director = "Director"
        case writer = "Writer"
        case actors = "Actors"
        case plot = "Plot"
        case language = "Language"
        case country = "Country"
        case awards = "Awards"
        case poster = "Poster"
        case ratings = "Ratings"
        case metascore = "Metascore"
        case imdbRating, imdbVotes, imdbID
        case type = "Type"
        case dvd = "DVD"
        case boxOffice = "BoxOffice"
        case production = "Production"
        case website = "Website"
        case response = "Response"
    }
    
    func convertToEntity(with tmdbDetail: TMDBMovieDetailDTO) -> MovieDetailBasicInfo {
        return MovieDetailBasicInfo(id: tmdbDetail.id,
                                    imdbID: tmdbDetail.imdbID ?? "",
                                    rating: tmdbDetail.voteAverage,
                                    posterPath: tmdbDetail.posterPath,
                                    title: tmdbDetail.title,
                                    genre: self.genre,
                                    year: self.year,
                                    runtime: self.runtime,
                                    plot: self.plot,
                                    actors: self.actors)
    }
}

// MARK: - RatingDTO
struct RatingDTO: Codable {
    let source: String
    let value: String

    enum CodingKeys: String, CodingKey {
        case source = "Source"
        case value = "Value"
    }
}
