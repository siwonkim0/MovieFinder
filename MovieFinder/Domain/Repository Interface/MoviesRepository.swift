//
//  MoviesRepository.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/06/19.
//

import Foundation
import RxSwift

protocol MoviesRepository {
    func getMovieListItem(from url: URL?) -> Observable<[MovieListItem]>
    func getMovieDetail(with id: Int) -> Observable<MovieDetailBasicInfo>
    func getMovieDetailReviews(with id: Int) -> Observable<[MovieDetailReview]>
    func updateMovieRating(of id: Int, to rating: Double) -> Observable<Bool>
}
