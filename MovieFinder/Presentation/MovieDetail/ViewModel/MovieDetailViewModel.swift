//
//  MovieDetailViewModel.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/19.
//

import Foundation
import RxSwift
import RxCocoa

final class MovieDetailViewModel: ViewModelType {
    struct Input {
        let viewWillAppear: Observable<Void>
        let tapRatingButton: Observable<Double>
        let tapCollectionViewCell: Observable<UUID?>
    }
    
    struct Output {
        let basicInfo: Driver<BasicInfoCellViewModel>
        let reviews: Driver<[MovieDetailReview]>
        let updateReviewState: Driver<MovieDetailReview.ID>
    }
    
    private let movieID: Int
    private let moviesUseCase: MoviesUseCase
    private let accountUseCase: MoviesAccountUseCase
    var basicInfo: BasicInfoCellViewModel?
    var reviews: [MovieDetailReview]?
    
    init(movieID: Int, moviesUseCase: MoviesUseCase, accountUseCase: MoviesAccountUseCase) {
        self.movieID = movieID
        self.moviesUseCase = moviesUseCase
        self.accountUseCase = accountUseCase
    }
    
    func transform(_ input: Input) -> Output {
        let reviews = input.viewWillAppear
            .take(1)
            .withUnretained(self)
            .flatMap { (self, _) -> Observable<[MovieDetailReview]> in
                return self.moviesUseCase.getMovieDetailReviews(with: self.movieID)
                    .withUnretained(self)
                    .map { (self, reviews) -> [MovieDetailReview] in
                        self.reviews = reviews
                        return reviews
                    }
            }.asDriver(onErrorJustReturn: [
                MovieDetailReview(
                    userName: "N/A",
                    rating: 0,
                    content: "N/A",
                    contentOriginal: "N/A",
                    contentPreview: "N/A",
                    createdAt: "N/A"
                )])
        
        let basicInfo = input.viewWillAppear
            .withUnretained(self)
            .flatMapLatest { (self, _) in
                self.moviesUseCase.getMovieDetail(with: self.movieID)
            }
            .map { (basicInfo) -> BasicInfoCellViewModel in
                let basicInfo = BasicInfoCellViewModel(movie: basicInfo)
                self.basicInfo = basicInfo
                return basicInfo
            }
            .take(1)
            .asDriver(onErrorJustReturn: BasicInfoCellViewModel(
                movie: MovieDetailBasicInfo(
                    id: 0,
                    imdbID: "N/A",
                    rating: 0,
                    posterPath: "N/A",
                    title: "N/A",
                    genre: "N/A",
                    year: "N/A",
                    runtime: "N/A",
                    plot: "N/A",
                    actors: "N/A"
                )))
        
        let updateReviewState = input.tapCollectionViewCell
            .compactMap { $0 }
            .skip(1)
            .withUnretained(self)
            .map { (self, reviewID) -> MovieDetailReview.ID in
                self.toggle(with: reviewID)
                self.updateReviewState(of: reviewID)
                return reviewID
            }
            .asDriver(onErrorJustReturn: UUID())
        
        return Output(
            basicInfo: basicInfo,
//            plot: plot,
            reviews: reviews,
            updateReviewState: updateReviewState
        )
    }
    
    private func toggle(with reviewID: MovieDetailReview.ID) {
        guard var selectedReview = reviews?.filter({ $0.id == reviewID }).first else {
            return
        }
        selectedReview.showAllContent.toggle()
        if let index = reviews?.firstIndex(where: { $0.id == reviewID }) {
            reviews?[index] = selectedReview
        }
    }
    
    private func updateReviewState(of reviewID: MovieDetailReview.ID) {
        guard var selectedReview = reviews?.filter({ $0.id == reviewID }).first else {
            return
        }
        if selectedReview.showAllContent {
            selectedReview.content = selectedReview.contentOriginal
        } else {
            selectedReview.content = selectedReview.contentPreview
        }
        if let index = reviews?.firstIndex(where: { $0.id == reviewID }) {
            reviews?[index] = selectedReview
        }
    }
    
}
