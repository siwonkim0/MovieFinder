//
//  AccountViewModelTests.swift
//  MovieFinderUnitTests
//
//  Created by Siwon Kim on 2022/09/09.
//

import XCTest
@testable import MovieFinder

import RxSwift

final class AccountViewModelTests: XCTestCase {
    private var disposeBag: DisposeBag!
    private var accountUseCase: SpyAccountUseCase!
    private var viewModel: MyAccountViewModel!
    private var output: MyAccountViewModel.Output!
    private var viewWillAppearSubject: BehaviorSubject<Void>!
    private var tapRatingButtonSubject: BehaviorSubject<RatedMovie>!
    
    override func setUp() {
        disposeBag = DisposeBag()
        viewWillAppearSubject = BehaviorSubject<Void>(value: ())
        tapRatingButtonSubject = BehaviorSubject<RatedMovie>(value: RatedMovie(movieId: 0, rating: 0))
        accountUseCase = SpyAccountUseCase()
        viewModel = MyAccountViewModel(
            useCase: accountUseCase
        )
        
        output = viewModel.transform(.init(
            viewWillAppear: viewWillAppearSubject.asObservable(),
            tapRatingButton: tapRatingButtonSubject.asObservable()
        ))
    }
    
    func test_ratingList() {
        viewWillAppearSubject.onNext(())
        output.ratingList
            .drive(onNext: { list in
                XCTAssertEqual(list[0].rating, 4)
                self.accountUseCase.verifyGetTotalRatedList(callCount: 1)
            })
            .disposed(by: disposeBag)
    }
    
    func test_updateRating() {
        let ratedMovie = RatedMovie(movieId: 0, rating: 1.3)
        tapRatingButtonSubject.onNext(ratedMovie)
        output.ratingDone
            .emit(onNext: { updatedMovieId in
                XCTAssertEqual(updatedMovieId.movieId, -10)
                self.accountUseCase.verifyUpdateMovieRating(callCount: 1)
            })
            .disposed(by: disposeBag)
    }

}
