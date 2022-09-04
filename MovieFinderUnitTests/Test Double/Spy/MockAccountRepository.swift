//
//  MockAccountRepository.swift
//  MovieFinderUnitTests
//
//  Created by Siwon Kim on 2022/09/01.
//

import XCTest
@testable import MovieFinder

import RxSwift

final class MockAccountRepository: MovieAccountRepository {
    private var saveAccountIdCallCount: Int = 0
    private var updateMovieRatingCallCount: Int = 0
    private var getMovieRatingCallCount: Int = 0
    
    func saveAccountId() -> Observable<Data> {
        let data = Data()
        return Observable.just(data)
    }
    
    func updateMovieRating(of id: Int, to rating: Double) -> Observable<Bool> {
        let bool = true
        return Observable.just(bool)
    }
    
    func getMovieRating(of id: Int) -> Observable<Double> {
        let bool = 1.0
        return Observable.just(bool)
    }
    
    func verifySaveAccountId(callCount: Int) {
        saveAccountIdCallCount += 1
        XCTAssertEqual(saveAccountIdCallCount, callCount)
    }
    
    func verifyUpdateMovieRating(callCount: Int) {
        updateMovieRatingCallCount += 1
        XCTAssertEqual(updateMovieRatingCallCount, callCount)
    }
    
    func verifyGetMovieRating(callCount: Int) {
        getMovieRatingCallCount += 1
        XCTAssertEqual(getMovieRatingCallCount, callCount)
    }
    

}
