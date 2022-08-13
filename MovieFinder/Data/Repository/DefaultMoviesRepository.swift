//
//  Repository.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/26.
//

import Foundation
import RxSwift

final class DefaultMoviesRepository: MoviesRepository {
    let apiManager: APIManager
    
    init(apiManager: APIManager) {
        self.apiManager = apiManager
    }
    
    func getMovieListItem(from url: URL?) -> Observable<[MovieListItem]> {
        let genres = apiManager.getData(from: MovieURL.genres.url, format: GenresDTO.self)
        let movies = apiManager.getData(from: url, format: MovieListDTO.self)
        
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
        let omdbMovieDetail = apiManager.getData(from: MovieURL.details(id: id).url, format: TMDBMovieDetailDTO.self)
            .withUnretained(self)
            .flatMap { (self, detail) in
                return self.apiManager.getData(from: MovieURL.omdbDetails(id: detail.imdbID!).url, format: OMDBMovieDetailDTO.self)
            }
        let tmdbMovieDetail = apiManager.getData(from: MovieURL.details(id: id).url, format: TMDBMovieDetailDTO.self)
        return Observable.zip(omdbMovieDetail, tmdbMovieDetail)
            .map { omdb, tmdb in
                omdb.convertToEntity(with: tmdb)
            }
    }
    
    func getMovieDetailReviews(with id: Int) -> Observable<[MovieDetailReview]> {
        let reviews = apiManager.getData(from: MovieURL.details(id: id).url, format: TMDBMovieDetailDTO.self)
            .withUnretained(self)
            .flatMap { (self, detail) in
                return self.apiManager.getData(from: MovieURL.reviews(id: id).url, format: ReviewListDTO.self)
            }
            .map { reviews in
                reviews.results.map { reviewDTO in
                    MovieDetailReview(username: reviewDTO.author,
                                      rating: reviewDTO.authorDetails.rating ?? 0,
                                      content: reviewDTO.content,
                                      createdAt: reviewDTO.createdAt
                    )
                }
            }
        return reviews
    }
    
    func updateMovieRating(of id: Int, to rating: Double) -> Observable<Bool> {
        let data = JSONParser.encodeToData(with: ["value": rating])
        return apiManager.postData(data, to: MovieURL.rateMovie(sessionID: KeychainManager.shared.getSessionID(), movieID: id).url, format: RateRespondDTO.self)
            .map { respond in
                return respond.success
            }
    }
    
    func getMovieRating(of id: Int) -> Observable<Double> {
        return apiManager.getData(from: MovieURL.ratedMovies(sessionID: KeychainManager.shared.getSessionID(), accountID: KeychainManager.shared.getAccountID()).url, format: RatedMovieListDTO.self)
            .map { movieList in
                guard let ratedMovie = movieList.results.filter({ $0.id == id }).first else {
                    return 0
                }
                return ratedMovie.rating
            }
    }

}
