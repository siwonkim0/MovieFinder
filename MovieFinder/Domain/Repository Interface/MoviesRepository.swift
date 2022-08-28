//
//  MoviesRepository.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/06/19.
//

import Foundation
import RxSwift

protocol MoviesRepository {
    func getMovieList(with path: String) -> Observable<MovieListDTO>
    func getOmdbMovieDetail(with id: Int) -> Observable<OMDBMovieDetailDTO>
    func getTmdbMovieDetail(with id: Int) -> Observable<TMDBMovieDetailDTO>
    func getMovieDetailReviews(with id: Int) -> Observable<ReviewListDTO>
    func getGenresList() -> Observable<GenresDTO>
    func getSearchResultList(with keyword: String, page: Int) -> Observable<MovieListDTO>
}
