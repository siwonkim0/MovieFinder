//
//  DefaultMoviesRepository.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/26.
//

import Foundation
import RxSwift

final class DefaultMoviesRepository: MoviesRepository {
    private let urlSessionManager: URLSessionManager
    
    init(urlSessionManager: URLSessionManager) {
        self.urlSessionManager = urlSessionManager
    }
    
    func getMovieList(with path: String) -> Observable<MovieListDTO> {
        let request = ListRequest(urlPath: path)
        return urlSessionManager.performDataTask(with: request)
    }
    
    func getGenresList() -> Observable<GenresDTO> {
        let genresRequest = GenresRequest()
        return urlSessionManager.performDataTask(with: genresRequest)
    }
    
    func getSearchResultList(with keyword: String, page: Int) -> Observable<MovieListDTO> {
        let keywordRequest = KeywordRequest(
            queryParameters: [
                "api_key": ApiKey.tmdb.description,
                "query": "\(keyword)",
                "page": "\(page)",
                "include_adult": "false"
            ]
        )
        return urlSessionManager.performDataTask(with: keywordRequest)
    }

    func getOmdbMovieDetail(with id: Int) -> Observable<OMDBMovieDetailDTO> {
        let tmdbRequest = DetailMovieInfoRequest(urlPath: "movie/\(id)?")
        return urlSessionManager.performDataTask(with: tmdbRequest)
            .withUnretained(self)
            .flatMap { (self, detail) -> Observable<OMDBMovieDetailDTO> in
                let id = detail.imdbID ?? ""
                let omdbRequest = DetailOmdbMovieInfoRequest(
                    urlPath: "?\(id)",
                    queryParameters: [
                        "apikey": ApiKey.omdb.description,
                        "i": "\(id)"
                    ])
                return self.urlSessionManager.performDataTask(with: omdbRequest)
            }
    }
    
    func getTmdbMovieDetail(with id: Int) -> Observable<TMDBMovieDetailDTO> {
        let tmdbRequest = DetailMovieInfoRequest(urlPath: "movie/\(id)?")
        return urlSessionManager.performDataTask(with: tmdbRequest)
    }
    
    func getMovieDetailReviews(with id: Int) -> Observable<ReviewListDTO> {
        let reviewsRequest = ReviewsRequest(
            urlPath: "movie/\(id)/reviews?",
            queryParameters: [
                "api_key": ApiKey.tmdb.description,
                "i": "\(id)"
            ]
        )
        return urlSessionManager.performDataTask(with: reviewsRequest)
    }

}
