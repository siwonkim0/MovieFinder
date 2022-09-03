//
//  MovieAccountRepository.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/08/13.
//

import Foundation
import RxSwift

protocol MovieAccountRepository {
    func saveAccountId() -> Observable<Data>
    func updateMovieRating(of id: Int, to rating: Double) -> Observable<Bool>
    func getMovieRating(of id: Int) -> Observable<Double>
    func getTotalRatedList() -> Observable<[MovieListItemDTO]>
}
