//
//  MovieDetailViewReactorTests.swift
//  MovieFinderUnitTests
//
//  Created by Siwon Kim on 2022/10/14.
//

import XCTest
@testable import MovieFinder

import RxSwift

final class MovieDetailViewReactorTests: XCTestCase {
    private var reactor: MovieDetailReactor!
    private var spyUseCase: SpyDefaultMoviesUseCase!
    private var spyAccountUseCase: SpyAccountUseCase!
    
    override func setUp() {
        spyUseCase = SpyDefaultMoviesUseCase()
        spyAccountUseCase = SpyAccountUseCase()
        reactor = MovieDetailReactor(movieID: 1, moviesUseCase: spyUseCase, accountUseCase: spyAccountUseCase)
    }
    
    func test_setInitialResults() {
        reactor.action.onNext(.setInitialData)
        
        XCTAssertEqual(reactor.currentState.basicInfos?.id, -1)
        XCTAssertEqual(reactor.currentState.reviews?.count, 1)
        
        spyUseCase.verifyGetMovieDetail(callCount: 1)
        spyAccountUseCase.verifyGetMovieRating(callCount: 1)
        spyUseCase.verifyGetMovieDetailReviews(callCount: 1)
    }
    
    func test_updateRating() {
        reactor.action.onNext(.rate(.init(movieId: 1, rating: 3.0)))
        XCTAssertEqual(reactor.currentState.rating, 3.0)
        
        spyAccountUseCase.verifyUpdateMovieRating(callCount: 1)
    }
    
    func test_updateReviewState() {
        let review = MovieDetailReview(
            userName: "",
            rating: 1.0,
            content: "",
            contentOriginal: "",
            contentPreview: "",
            createdAt: ""
        )
        
        reactor.initialState.reviews = [review]
        reactor.action.onNext(.setReviewState(review.id))
        XCTAssertEqual(reactor.currentState.selectedReviewID, review.id)
        XCTAssertEqual(reactor.currentState.reviews?[0].showAllContent, true)
    }
}
