//
//  AccountUseCaseTests.swift
//  MovieFinderUnitTests
//
//  Created by Siwon Kim on 2022/09/01.
//

import XCTest
@testable import MovieFinder

import RxSwift

class AccountUseCaseTests: XCTestCase {
    private var disposeBag: DisposeBag!
    private var accountRepository: MockAccountRepository!
    private var useCase: AccountUseCase!
    
    override func setUp() {
        disposeBag = DisposeBag()
        accountRepository = MockAccountRepository()
        useCase = AccountUseCase(accountRepository: accountRepository)
    }
    
    func test_updateMovieRating() {
        let id = 1
        let newRating = 3.0
        useCase.updateMovieRating(of: id, to: newRating)
            .subscribe(onNext: { isUpdated in
                XCTAssertEqual(isUpdated, true)
                self.accountRepository.verifyUpdateMovieRating(callCount: 1)
            })
            .disposed(by: disposeBag)
    }
    
    func test_getMovieRating() {
        let id = 1
        useCase.getMovieRating(of: id)
            .subscribe(onNext: { rating in
                XCTAssertEqual(rating, 1.0)
                self.accountRepository.verifyGetMovieRating(callCount: 1)
            })
            .disposed(by: disposeBag)
    }
}
