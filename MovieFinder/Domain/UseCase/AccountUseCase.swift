//
//  AccountUseCase.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/08/27.
//

import Foundation
import RxSwift

enum AccountError: Error {
    case rating
}

protocol MoviesAccountUseCase {
    func updateMovieRating(of id: Int, to rating: Double) -> Observable<RatedMovie>
    func getMovieRating(of id: Int) -> Observable<Double>
    func getTotalRatedList() -> Observable<[MovieListItem]>
}

final class AccountUseCase: MoviesAccountUseCase {
    private let accountRepository: MovieAccountRepository
    
    init(accountRepository: MovieAccountRepository) {
        self.accountRepository = accountRepository
    }
    
    func updateMovieRating(of id: Int, to rating: Double) -> Observable<RatedMovie> {
        return accountRepository.updateMovieRating(of: id, to: rating)
            .map { bool in
                if bool {
                    return RatedMovie(movieId: id, rating: rating)
                } else {
                    return RatedMovie(movieId: 0, rating: 0)
                }
            }
    }
    
    func getMovieRating(of id: Int) -> Observable<Double> {
        return accountRepository.getMovieRating(of: id)
    }
    
    func getTotalRatedList() -> Observable<[MovieListItem]> {
        return accountRepository.getTotalRatedList()
            .map {
                $0.map {
                    $0.convertToEntity()
                }
            }
    }
}
