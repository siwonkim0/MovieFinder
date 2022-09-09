//
//  SearchViewModelTests.swift
//  MovieFinderUnitTests
//
//  Created by Siwon Kim on 2022/09/09.
//

import XCTest
@testable import MovieFinder

import RxSwift

final class SearchViewModelTests: XCTestCase {
    private var disposeBag: DisposeBag!
    private var useCase: SpyDefaultMoviesUseCase!
    private var viewModel: SearchViewModel!
    private var output: SearchViewModel.Output!
    private var searchBarTextSubject: PublishSubject<String>!
    private var searchCancelledSubject: PublishSubject<Void>!
    private var loadMoreContentSubject: PublishSubject<Bool>!
    
    override func setUp() {
        disposeBag = DisposeBag()
        searchBarTextSubject = PublishSubject<String>()
        searchCancelledSubject = PublishSubject<Void>()
        loadMoreContentSubject = PublishSubject<Bool>()
        useCase = SpyDefaultMoviesUseCase()
        viewModel = SearchViewModel(useCase: useCase)
        
        output = viewModel.transform(.init(
            searchBarText: searchBarTextSubject.asObservable(),
            searchCancelled: searchCancelledSubject.asObservable(),
            loadMoreContent: loadMoreContentSubject.asObservable()
        ))
    }
    //TODO
    func test_newSearchResults() {
        output.newSearchResults
            .emit(onNext: { resultList in
                XCTAssertEqual(resultList.count, 1)
                self.useCase.verifyGetSearchResults(callCount: 1)
            })
            .disposed(by: disposeBag)
        searchBarTextSubject.onNext("search")
    }
    
    func test_cancelResults() {
        output.cancelResults
            .emit(onNext: { resultList in
                XCTAssertEqual(resultList.count, 1)
            })
            .disposed(by: disposeBag)
        searchCancelledSubject.onNext(())
    }
    
    func test_moreResults() {
        output.moreResults
            .emit(onNext: { resultList in
                XCTAssertEqual(resultList.count, 1)
            })
            .disposed(by: disposeBag)
        loadMoreContentSubject.onNext(true)
    }
    
}

