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
                "page": "\(page)"
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
                        "i": "\(id)",
                        "apikey": ApiKey.omdb.description
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
                "i": "\(id)",
                "api_key": ApiKey.tmdb.description
            ]
        )
        return self.urlSessionManager.performDataTask(with: reviewsRequest)
    }

}
