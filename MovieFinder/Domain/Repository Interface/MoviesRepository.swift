//
//  MoviesRepository.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/06/19.
//

import Foundation
import RxSwift

protocol MoviesRepository {
    func getAllMovieLists() -> Observable<[[MovieListItem]]>
    func getOmdbMovieDetail(with id: Int) -> Observable<OMDBMovieDetailDTO>
    func getTmdbMovieDetail(with id: Int) -> Observable<TMDBMovieDetailDTO>
    func getMovieDetailReviews(with id: Int) -> Observable<[MovieReview]>
    func getSearchMovieList(with keyword: String) -> Observable<[MovieListItem]>
}
