//
//  MyAccountReactorTests.swift
//  MovieFinderUnitTests
//
//  Created by Siwon Kim on 2022/10/14.
//

import XCTest
@testable import MovieFinder

import RxSwift

final class MyAccountReactorTests: XCTestCase {
    private var reactor: MyAccountReactor!
    private var spyUseCase: SpyAccountUseCase!
    
    override func setUp() {
        spyUseCase = SpyAccountUseCase()
        reactor = MyAccountReactor(useCase: spyUseCase)
    }
    
    func test_setInitialData() {
        reactor.action.onNext(.setInitialData)
        XCTAssertEqual(reactor.currentState.movies[0].rating, 4)
        spyUseCase.verifyGetTotalRatedList(callCount: 1)
    }
    
    func test_updateRating() {
        let ratedMovie = RatedMovie(movieId: 1, rating: 1)
        reactor.action.onNext(.rate(ratedMovie))
        XCTAssertEqual(reactor.currentState.ratedMovie?.rating, 1)
        spyUseCase.verifyUpdateMovieRating(callCount: 1)
    }
}
