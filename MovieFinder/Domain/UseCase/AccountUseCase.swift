//
//  AccountUseCase.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/08/27.
//

import Foundation
import RxSwift

protocol MoviesAccountUseCase {
    func updateMovieRating(of id: Int, to rating: Double) -> Observable<Bool>
    func getMovieRating(of id: Int) -> Observable<Double>
}

final class AccountUseCase: MoviesAccountUseCase {
    private let accountRepository: MovieAccountRepository
    
    init(accountRepository: MovieAccountRepository) {
        self.accountRepository = accountRepository
    }
    
    func updateMovieRating(of id: Int, to rating: Double) -> Observable<Bool> {
        return accountRepository.updateMovieRating(of: id, to: rating)
    }
    
    func getMovieRating(of id: Int) -> Observable<Double> {
        return accountRepository.getMovieRating(of: id)
    }
}
