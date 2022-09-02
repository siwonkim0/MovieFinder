//
//  MovieListViewModelTests.swift
//  MovieFinderUnitTests
//
//  Created by Siwon Kim on 2022/09/01.
//

import XCTest
@testable import MovieFinder

import RxSwift

final class MovieListViewModelTests: XCTestCase {
    private var disposeBag: DisposeBag!
    private var useCase: MockDefaultMoviesUseCase!
    private var viewModel: MovieListViewModel!
    private var output: MovieListViewModel.Output!
    private var viewWillAppearSubject: BehaviorSubject<Void>!
    private var refreshSubject: BehaviorSubject<Void>!
    
    override func setUp() {
        disposeBag = DisposeBag()
        viewWillAppearSubject = BehaviorSubject<Void>(value: ())
        refreshSubject = BehaviorSubject<Void>(value: ())
        useCase = MockDefaultMoviesUseCase()
        viewModel = MovieListViewModel(defaultMoviesUseCase: useCase)
        
        output = viewModel.transform(.init(
            viewWillAppear: viewWillAppearSubject.asObservable(),
            refresh: refreshSubject.asObservable()
        ))
    }
    
    func test_section() {
        viewWillAppearSubject.onNext(())
        output.section
            .subscribe(onNext: { sections in
                print(sections)
                XCTAssertEqual(sections[0].title, "Now Playing")
                XCTAssertEqual(sections[1].title, "Upcoming")
                XCTAssertEqual(sections[2].title, "Top Rated")
                XCTAssertEqual(sections[3].title, "Popular")
                self.useCase.verifyGetMovieListsCallCount()
            })
            .disposed(by: disposeBag)
    }
    
    func test_refresh() {
        refreshSubject.onNext(())
        output.refresh
            .subscribe(onNext: { sections in
                XCTAssertEqual(sections[0].title, "Now Playing")
                XCTAssertEqual(sections[1].title, "Upcoming")
                XCTAssertEqual(sections[2].title, "Top Rated")
                XCTAssertEqual(sections[3].title, "Popular")
            })
            .disposed(by: disposeBag)
    }
    
}

