//
//  SpyAccountUseCase.swift
//  MovieFinderUnitTests
//
//  Created by Siwon Kim on 2022/09/02.
//

import XCTest
@testable import MovieFinder

import RxSwift

final class SpyAccountUseCase: MoviesAccountUseCase {
    private var updateMovieRatingCallCount: Int = 0
    private var getMovieRatingCallCount: Int = 0
    private var getTotalRatedListCallCount: Int = 0
    
    func updateMovieRating(of id: Int, to rating: Double) -> Observable<RatedMovie> {
        updateMovieRatingCallCount += 1
        return Observable.just(RatedMovie(movieId: -10, rating: 0))
    }
    
    func getTotalRatedList() -> Observable<[MovieListItem]> {
        getTotalRatedListCallCount += 1
        return Observable.just([
            MovieListItem(
                id: 0,
                title: "",
                overview: "",
                releaseDate: "",
                posterPath: "",
                originalLanguage: .english,
                genres: [],
                rating: 4
            )])
    }
    
    func getMovieRating(of id: Int) -> Observable<Double> {
        getMovieRatingCallCount += 1
        return Observable.just(1)
    }
    
    func verifyUpdateMovieRating(callCount: Int) {
        XCTAssertEqual(updateMovieRatingCallCount, callCount)
    }
    
    func verifyGetTotalRatedList(callCount: Int) {
        XCTAssertEqual(getTotalRatedListCallCount, callCount)
    }
    
    func verifyGetMovieRating(callCount: Int) {
        XCTAssertEqual(getMovieRatingCallCount, callCount)
    }
    

}
