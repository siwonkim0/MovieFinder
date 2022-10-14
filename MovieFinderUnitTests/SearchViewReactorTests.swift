//
//  SearchViewReactorTests.swift
//  MovieFinderUnitTests
//
//  Created by Siwon Kim on 2022/10/14.
//

import XCTest
@testable import MovieFinder

import RxSwift

final class SearchViewReactorTests: XCTestCase {
    private var reactor: SearchViewReactor!
    private var spyUseCase: SpyDefaultMoviesUseCase!
    
    override func setUp() {
        spyUseCase = SpyDefaultMoviesUseCase()
        reactor = SearchViewReactor(useCase: spyUseCase)
    }
    
    func test_setKeyword() {
        let keyword = "test"
        reactor.action.onNext(.searchKeyword(keyword))
        
        XCTAssertEqual(reactor.currentState.keyword, "test")
        XCTAssertEqual(reactor.currentState.movieResults.count, 2)
        spyUseCase.verifyGetSearchResults(callCount: 1)
    }
    
    func test_loadNextPage() {
        XCTAssertEqual(reactor.currentState.nextPage, 1)
        
        reactor.action.onNext(.loadNextPage)
        XCTAssertEqual(reactor.currentState.nextPage, 2)
        XCTAssertEqual(reactor.currentState.isLoadingNextPage, false)
    }
    
    func test_clearSearchKeyword() {
        reactor.initialState.keyword = "ask"
        
        reactor.action.onNext(.clearSearchKeyword)
        XCTAssertEqual(reactor.currentState.keyword, "")
        XCTAssertEqual(reactor.currentState.movieResults, [])
    }
    
}
