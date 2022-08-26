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
    
    func getAllMovieLists() -> Observable<[[MovieListItem]]> {
        let lists: [MovieLists: String] = [
            .nowPlaying: "movie/now_playing?",
            .popular: "movie/popular?",
            .topRated: "movie/top_rated?",
            .upComing: "movie/upcoming?"
        ]
        let movieLists = lists.map { (key, value) -> Observable<[MovieListItem]> in
            let request = ListRequest(urlPath: value)
            return getMovieList(from: request)
                .map { itemList in
                    itemList.map { item in
                        return MovieListItem(
                            id: item.id,
                            title: item.title ,
                            overview: item.overview,
                            releaseDate: item.releaseDate ,
                            posterPath: item.posterPath ,
                            originalLanguage: item.originalLanguage,
                            genres: item.genres,
                            section: key
                        )
                    }
                }
        }
        return Observable.zip(movieLists) { $0 }
    }
    
    private func getMovieList(from request: ListRequest) -> Observable<[MovieListItem]> {
        let genresRequest = GenresRequest()
        let genres = urlSessionManager.performDataTask(with: genresRequest)
        let movieList = urlSessionManager.performDataTask(with: request)
        
        return Observable.zip(genres, movieList) { genresList, movieList in
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
        let omdbMovieDetail = urlSessionManager.performDataTask(with: tmdbRequest)
            .withUnretained(self)
            .flatMap { (self, detail) -> Observable<OMDBMovieDetailDTO> in
                let id = detail.imdbID ?? ""
                let omdbRequest = DetailOmdbMovieInfoRequest(
                    urlPath: "?\(id)",
                    queryParameters: [
                        "i": "\(id)",
                        "apikey": ApiKey.omdb.description
                    ])
                return self.urlSessionManager.performDataTask(with: omdbRequest)
            }
        let tmdbMovieDetail = urlSessionManager.performDataTask(with: tmdbRequest)
        return Observable.zip(omdbMovieDetail, tmdbMovieDetail)
            .map { omdb, tmdb in
                return omdb.convertToEntity(with: tmdb)
            }
    }
    
    func getMovieDetailReviews(with id: Int) -> Observable<[MovieReview]> {
        let reviewsRequest = ReviewsRequest(
            urlPath: "movie/\(id)/reviews?",
            queryParameters: [
                "i": "\(id)",
                "api_key": ApiKey.tmdb.description
            ]
        )
        return self.urlSessionManager.performDataTask(with: reviewsRequest)
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
    
    func getSearchMovieList(with keyword: String) -> Observable<[MovieListItem]> {
        let keywordRequest = KeywordRequest(
            queryParameters: [
                "api_key": ApiKey.tmdb.description,
                "query": "\(keyword)"
            ]
        )
        let genresRequest = GenresRequest()
        let genres = urlSessionManager.performDataTask(with: genresRequest)
        let movieList = urlSessionManager.performDataTask(with: keywordRequest)
        return Observable.zip(genres, movieList) { genresList, movieList in
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

}
