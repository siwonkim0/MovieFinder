//
//  DefaultMoviesUseCaseTests.swift
//  MovieFinderUnitTests
//
//  Created by Siwon Kim on 2022/09/01.
//

import XCTest
@testable import MovieFinder

import RxSwift

final class DefaultMoviesUseCaseTests: XCTestCase {
    private var disposeBag: DisposeBag!
    private var defaultMoviesRepository: SpyDefaultMoviesRepository!
    private var useCase: DefaultMoviesUseCase!
    
    override func setUp() {
        disposeBag = DisposeBag()
        defaultMoviesRepository = SpyDefaultMoviesRepository()
        useCase = DefaultMoviesUseCase(moviesRepository: defaultMoviesRepository)
    }
    
    func test_getMovieLists() {
        useCase.getMovieLists()
            .subscribe(onNext: { movieLists in
                XCTAssertEqual(movieLists[0].section, .nowPlaying)
                XCTAssertEqual(movieLists[1].section, .popular)
                XCTAssertEqual(movieLists[2].section, .topRated)
                XCTAssertEqual(movieLists[3].section, .upComing)
                self.defaultMoviesRepository.verifyGetMovieList(callCount: 4)
            })
            .disposed(by: disposeBag)
    }
    
    func test_getSearchResults() {
        let string = "super"
        useCase.getSearchResults(with: string)
            .subscribe(onNext: { movieList in
                XCTAssertEqual(movieList.items[0].title, "super")
                self.defaultMoviesRepository.verifyGetSearchResultList(callCount: 1)
            })
            .disposed(by: disposeBag)
    }

    func test_getMovieDetail() {
        let id = 1
        useCase.getMovieDetail(with: id)
            .subscribe(onNext: { movieDetail in
                XCTAssertEqual(movieDetail.title, "super")
                self.defaultMoviesRepository.verifyGetOmdbMovieDetail(callCount: 1)
                self.defaultMoviesRepository.verifyGetTmdbMovieDetail(callCount: 1)
            })
            .disposed(by: disposeBag)
    }
    
    func test_getMovieDetailReviews_when_content_is_over_300_words() {
        let id = 1
        useCase.getMovieDetailReviews(with: id)
            .subscribe(onNext: { reviews in
                XCTAssertEqual(reviews[0].rating, 2.5)
                self.defaultMoviesRepository.verifyGetMovieDetailReviews(callCount: 1)
            })
            .disposed(by: disposeBag)
    }
    
    func test_getMovieDetailReviews_when_content_is_under_300_words() {
        let id = 1
        useCase.getMovieDetailReviews(with: id)
            .subscribe(onNext: { reviews in
                XCTAssertEqual(reviews[1].rating, 3)
                self.defaultMoviesRepository.verifyGetMovieDetailReviews(callCount: 1)
            })
            .disposed(by: disposeBag)
    }
}
