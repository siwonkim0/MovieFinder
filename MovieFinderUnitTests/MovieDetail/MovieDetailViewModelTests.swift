//
//  MovieDetailViewModelTests.swift
//  MovieFinderUnitTests
//
//  Created by Siwon Kim on 2022/09/02.
//

import XCTest
@testable import MovieFinder

import RxSwift
import RxTest
import RxNimble

final class MovieDetailViewModelTests: XCTestCase {
    private var scheduler: TestScheduler!
    private var disposeBag: DisposeBag!
    private var useCase: MockDefaultMoviesUseCase!
    private var accountUseCase: MockAccountUseCase!
    private var viewModel: MovieDetailViewModel!
    private var output: MovieDetailViewModel.Output!
    private var viewWillAppearSubject: BehaviorSubject<Void>!
    private var tapRatingButtonSubject: BehaviorSubject<Double>!
    private var movieID: Int!
    
    override func setUp() {
//        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
        viewWillAppearSubject = BehaviorSubject<Void>(value: ())
        tapRatingButtonSubject = BehaviorSubject<Double>(value: 2.0)
        useCase = MockDefaultMoviesUseCase()
        accountUseCase = MockAccountUseCase()
        movieID = 1
        viewModel = MovieDetailViewModel(
            movieID: movieID,
            moviesUseCase: useCase,
            accountUseCase: accountUseCase
        )
        
        output = viewModel.transform(.init(
            viewWillAppear: viewWillAppearSubject.asObservable(),
            tapRatingButton: tapRatingButtonSubject.asObservable()
        ))
    }
    
    func test_reviews() {
//        scheduler.createColdObservable([
//            .next(10, ())
//        ]).bind(to: viewWillAppearSubject).disposed(by: disposeBag)
        viewWillAppearSubject.onNext(())
        output.reviews
            .drive(onNext: { reviews in
                XCTAssertEqual(reviews[0].rating, 1.0)
                self.useCase.verifyGetMovieDetailReviewsCallCount()
            })
            .disposed(by: disposeBag)
    }
    
    func test_imageUrl() {
        viewWillAppearSubject.onNext(())
        output.imageUrl
            .drive(onNext: { url in
                XCTAssertEqual(url.absoluteString, "https://image.tmdb.org/t/p/original/posterPath?api_key=171386c892bc41b9cf77e320a01d6945")
                self.useCase.verifyGetMovieDetailCallCount()
            })
            .disposed(by: disposeBag)
    }
    
    func test_title() {
        viewWillAppearSubject.onNext(())
        output.title
            .drive(onNext: { title in
                XCTAssertEqual(title, "title")
                self.useCase.verifyGetMovieDetailCallCount()
            })
            .disposed(by: disposeBag)
    }
    
    func test_description() {
        viewWillAppearSubject.onNext(())
        output.description
            .drive(onNext: { description in
                XCTAssertEqual(description, "year • genre • runtime")
                self.useCase.verifyGetMovieDetailCallCount()
            })
            .disposed(by: disposeBag)
    }
    
    func test_averageRating() {
        viewWillAppearSubject.onNext(())
        output.averageRating
            .drive(onNext: { description in
                XCTAssertEqual(description, "⭐ 0.5")
                self.useCase.verifyGetMovieDetailCallCount()
            })
            .disposed(by: disposeBag)
    }
    
    func test_plot() {
        viewWillAppearSubject.onNext(())
        output.plot
            .drive(onNext: { description in
                XCTAssertEqual(description, "plot")
                self.useCase.verifyGetMovieDetailCallCount()
            })
            .disposed(by: disposeBag)
    }
    
    func test_myRating() {
        viewWillAppearSubject.onNext(())
        output.myRating
            .drive(onNext: { rating in
                XCTAssertEqual(rating, 1.0)
                self.accountUseCase.verifyGetMovieRating()
            })
            .disposed(by: disposeBag)
    }
    
    func test_updateRating() {
        viewWillAppearSubject.onNext(())
        output.updateRating
            .drive(onNext: { isupdated in
                XCTAssertEqual(isupdated, true)
                self.accountUseCase.verifyUpdateMovieRating()
            })
            .disposed(by: disposeBag)
    }
    
    
}
