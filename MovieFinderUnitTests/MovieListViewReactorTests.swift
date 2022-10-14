//
//  MovieListViewReactorTests.swift
//  MovieFinderUnitTests
//
//  Created by Siwon Kim on 2022/10/14.
//

import XCTest
@testable import MovieFinder

import RxSwift

final class MovieListViewReactorTests: XCTestCase {
    var reactor: MovieListReactor!
    var spyUseCase: SpyDefaultMoviesUseCase!
    
    override func setUp() {
        spyUseCase = SpyDefaultMoviesUseCase()
        reactor = MovieListReactor(useCase: spyUseCase)
    }
    
    func test_setInitialResults() {
        reactor.action.onNext(.setInitialResults)
        
        XCTAssertEqual(reactor.currentState.movieResults[0].title, "Now Playing")
        spyUseCase.verifyGetMovieLists(callCount: 1)
    }
    
    func test_refresh() {
        reactor.action.onNext(.refresh)
        XCTAssertEqual(reactor.currentState.isLoading, false)
        spyUseCase.verifyGetMovieLists(callCount: 1)
    }
}
