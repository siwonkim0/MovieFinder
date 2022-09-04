//
//  MockAccountUseCase.swift
//  MovieFinderUnitTests
//
//  Created by Siwon Kim on 2022/09/02.
//

import XCTest
@testable import MovieFinder

import RxSwift

final class MockAccountUseCase: MoviesAccountUseCase {
    private var updateMovieRatingCallCount: Int = 0
    private var getMovieRatingCallCount: Int = 0
    
    func updateMovieRating(of id: Int, to rating: Double) -> Observable<Bool> {
        updateMovieRatingCallCount += 1
        return Observable.just(true)
    }
    
    func getMovieRating(of id: Int) -> Observable<Double> {
        getMovieRatingCallCount += 1
        return Observable.just(1.0)
    }
    
    func verifyUpdateMovieRating() {
        XCTAssertEqual(updateMovieRatingCallCount, 1)
    }
    
    func verifyGetMovieRating() {
        XCTAssertEqual(getMovieRatingCallCount, 1)
    }
    

}
