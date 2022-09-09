//
//  MovieDetailViewModelTests.swift
//  MovieFinderUnitTests
//
//  Created by Siwon Kim on 2022/09/02.
//

import XCTest
@testable import MovieFinder

import RxSwift

final class MovieDetailViewModelTests: XCTestCase {
    private var disposeBag: DisposeBag!
    private var useCase: SpyDefaultMoviesUseCase!
    private var accountUseCase: SpyAccountUseCase!
    private var viewModel: MovieDetailViewModel!
    private var output: MovieDetailViewModel.Output!
    private var viewWillAppearSubject: BehaviorSubject<Void>!
    private var tapRatingButtonSubject: BehaviorSubject<RatedMovie>!
    private var tapCollectionViewCellSubject: BehaviorSubject<UUID?>!
    private var movieID: Int!
    
    override func setUp() {
        disposeBag = DisposeBag()
        viewWillAppearSubject = BehaviorSubject<Void>(value: ())
        tapRatingButtonSubject = BehaviorSubject<RatedMovie>(value: RatedMovie(movieId: 0, rating: 0))
        tapCollectionViewCellSubject = BehaviorSubject<UUID?>(value: nil)
        useCase = SpyDefaultMoviesUseCase()
        accountUseCase = SpyAccountUseCase()
        movieID = 1
        viewModel = MovieDetailViewModel(
            movieID: movieID,
            moviesUseCase: useCase,
            accountUseCase: accountUseCase
        )
        
        output = viewModel.transform(.init(
            viewWillAppear: viewWillAppearSubject.asObservable(),
            tapRatingButton: tapRatingButtonSubject.asObservable(),
            tapCollectionViewCell: tapCollectionViewCellSubject.asObservable()
        ))
    }
    
    func test_basicInfo() {
        viewWillAppearSubject.onNext(())
        output.basicInfo
            .drive(onNext: { basicInfo in
                XCTAssertEqual(basicInfo.id, -1)
                self.useCase.verifyGetMovieDetail(callCount: 1)
                self.accountUseCase.verifyGetMovieRating(callCount: 1)
            })
            .disposed(by: disposeBag)
    }
    
    func test_updateRating() {
        let ratedMovie = RatedMovie(movieId: 0, rating: 1.3)
        tapRatingButtonSubject.onNext(ratedMovie)
        output.ratingDone
            .emit(onNext: { updatedMovieId in
                XCTAssertEqual(updatedMovieId.movieId, -10)
                self.accountUseCase.verifyUpdateMovieRating(callCount: 1)
            })
            .disposed(by: disposeBag)
    }
    
    func test_reviews() {
        viewWillAppearSubject.onNext(())
        output.reviews
            .drive(onNext: { reviews in
                XCTAssertEqual(reviews[0].rating, 1.0)
                self.useCase.verifyGetMovieDetailReviews(callCount: 1)
            })
            .disposed(by: disposeBag)
    }
    
    func test_updateReviewState() {
        viewModel.reviews = [
            MovieDetailReview(
                userName: "",
                rating: -1,
                content: "",
                contentOriginal: "original",
                contentPreview: "preview",
                createdAt: "",
                showAllContent: false
            )]
        tapCollectionViewCellSubject.onNext(viewModel.reviews?[0].id)
        output.updateReviewState
            .drive(onNext: { reviewId in
                let review = self.viewModel.reviews?[0]
                XCTAssertEqual(review?.showAllContent, true)
                XCTAssertEqual(review?.content, "original")
            })
            .disposed(by: disposeBag)
    }
    
//    func test_plot() {
//        viewWillAppearSubject.onNext(())
//        output.plot
//            .drive(onNext: { description in
//                XCTAssertEqual(description, "plot")
//                self.useCase.verifyGetMovieDetailCallCount()
//            })
//            .disposed(by: disposeBag)
//    }
    
    
}
