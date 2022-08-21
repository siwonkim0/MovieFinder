//
//  Repository.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/26.
//

import Foundation
import RxSwift

final class DefaultMoviesRepository: MoviesRepository {
    let urlSessionManager: URLSessionManager
    
    init(urlSessionManager: URLSessionManager) {
        self.urlSessionManager = urlSessionManager
    }
    
    func getMovieListItem(from url: URL?) -> Observable<[MovieListItem]> {
        let genres = urlSessionManager.getData(from: MovieURL.genres.url, format: GenresDTO.self)
        let movies = urlSessionManager.getData(from: url, format: MovieListDTO.self)
        
        return Observable.zip(genres, movies) { genresList, movieList in
            return movieList.results.map { movieListItemDTO -> MovieListItem in
                var movieGenres: [Genre] = []
                movieListItemDTO.genreIDS.forEach { genreID in
                    genresList.genres.forEach { genre in
                        if genreID == genre.id {
                            movieGenres.append(genre)
                        }
                    }
                }
                return movieListItemDTO.convertToEntity(with: movieGenres)
            }
        }
    }
    
    func getMovieDetail(with id: Int) -> Observable<MovieDetailBasicInfo> {
        let tmdbRequest = DetailMovieInfoRequest(urlPath: "movie/\(id)?")
        let omdbMovieDetail = urlSessionManager.performDataTask2(with: tmdbRequest)
            .withUnretained(self)
            .flatMap { (self, detail) ->
                Observable<OMDBMovieDetailDTO> in
                let id = detail.imdbID ?? ""
                let omdbRequest = DetailOmdbMovieInfoRequest(
                    urlPath: "?\(id)",
                    queryParameters: ["i": "\(id)",
                                      "apikey": ApiKey.omdb.description]
                )
                return self.urlSessionManager.performDataTask2(with: omdbRequest)
            }
        let tmdbMovieDetail = urlSessionManager.performDataTask2(with: tmdbRequest)
        return Observable.zip(omdbMovieDetail, tmdbMovieDetail)
            .map { omdb, tmdb in
                return omdb.convertToEntity(with: tmdb)
            }
    }
    
    func getMovieDetailReviews(with id: Int) -> Observable<[MovieReview]> {
        let reviewsRequest = ReviewsRequest(
            urlPath: "movie/\(id)/reviews?",
            queryParameters: ["i": "\(id)",
                              "api_key": ApiKey.tmdb.description]
        )
        return self.urlSessionManager.performDataTask2(with: reviewsRequest)
            .map { reviews in
                reviews.results.map { reviewDTO in
                    MovieReview(username: reviewDTO.author,
                                rating: reviewDTO.authorDetails.rating ?? 0,
                                content: reviewDTO.content,
                                createdAt: reviewDTO.createdAt
                    )
                }
            }
    }

}
