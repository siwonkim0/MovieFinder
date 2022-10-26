//
//  SpyAccountRepository.swift
//  MovieFinderUnitTests
//
//  Created by Siwon Kim on 2022/09/01.
//

import XCTest
@testable import MovieFinder

import RxSwift

final class SpyAccountRepository: MovieAccountRepository {
    private var saveAccountIdCallCount: Int = 0
    private var updateMovieRatingCallCount: Int = 0
    private var getMovieRatingCallCount: Int = 0
    private var getTotalRatedListCallCount: Int = 0
    
    func saveAccountId() -> Observable<Data> {
        saveAccountIdCallCount += 1
        let data = Data()
        return Observable.just(data)
    }
    
    func updateMovieRating(of id: Int, to rating: Double) -> Observable<Bool> {
        updateMovieRatingCallCount += 1
        let bool = true
        return Observable.just(bool)
    }
    
    func getMovieRating(of id: Int) -> Observable<Double> {
        getMovieRatingCallCount += 1
        let rating = 1.0
        return Observable.just(rating)
    }
    
    func getTotalRatedList() -> Observable<[MovieListItemDTO]> {
        getTotalRatedListCallCount += 1
        let ratedList = [
            MovieListItemDTO(
                adult: false,
                backdropPath: "",
                genreIDS: [0],
                id: 1,
                originalLanguage: "",
                originalTitle: "",
                overview: "",
                popularity: 0,
                posterPath: "",
                releaseDate: "",
                title: "rated",
                video: false,
                voteAverage: 0,
                voteCount: 0,
                rating: 1.0
            ),
            MovieListItemDTO(
                adult: false,
                backdropPath: "",
                genreIDS: [0],
                id: 0,
                originalLanguage: "",
                originalTitle: "",
                overview: "",
                popularity: 0,
                posterPath: "",
                releaseDate: "",
                title: "",
                video: false,
                voteAverage: 0,
                voteCount: 0,
                rating: 0
            )]
        return Observable.just(ratedList)
    }
    
    
    func verifySaveAccountId(callCount: Int) {
        XCTAssertEqual(saveAccountIdCallCount, callCount)
    }
    
    func verifyUpdateMovieRating(callCount: Int) {
        XCTAssertEqual(updateMovieRatingCallCount, callCount)
    }
    
    func verifyGetMovieRating(callCount: Int) {
        XCTAssertEqual(getMovieRatingCallCount, callCount)
    }
    
    func verifyGetTotalRatedList(callCount: Int) {
        XCTAssertEqual(getTotalRatedListCallCount, callCount)
    }
    

}
