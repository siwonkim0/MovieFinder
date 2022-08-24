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
    func getMovieDetail(with id: Int) -> Observable<MovieDetailBasicInfo>
    func getMovieDetailReviews(with id: Int) -> Observable<[MovieReview]>
    func getSearchMovieList(with keyword: String) -> Observable<[MovieListItem]>
}
