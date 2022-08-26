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
    }
    
    struct Output {
        let imageUrlObservable: Observable<URL>
        let titleObservable: Observable<String>
        let descriptionObservable: Observable<String>
        let rateObservable: Observable<String>
        let plotObservable: Observable<String>
        let reviewsObservable: Observable<[MovieDetailReview]>
        let ratingDriver: Driver<Bool>
        let ratingObservable: Observable<Double>
    }
    
    private let movieID: Int
    private let useCase: MoviesUseCase
    var reviews: [MovieDetailReview]?
    
    init(movieID: Int, useCase: MoviesUseCase) {
        self.movieID = movieID
        self.useCase = useCase
    }
    
    func transform(_ input: Input) -> Output {
        let reviewsObservable = input.viewWillAppear
            .withUnretained(self)
            .flatMap { (self, _) -> Observable<[MovieDetailReview]> in
                return self.useCase.getMovieDetailReviews(from: self.movieID)
                    .map { reviews -> [MovieDetailReview] in
                        self.reviews = reviews
                        return reviews
                    }
            }
        let basicInfo = input.viewWillAppear
            .withUnretained(self)
            .flatMapLatest { (self, _) in
                self.useCase.getMovieDetailItem(from: self.movieID)
            }
            .take(1)
            .share()
        
        let imageUrl = basicInfo
            .map { basicInfo -> URL in
            guard let posterPath = basicInfo.posterPath,
                  let url = ImageRequest(urlPath: "\(posterPath)").urlComponents else {
                return URL(string: "")!
            }
            return url
        }
        let title = basicInfo
            .map { $0.title }
        
        let description = basicInfo
            .map { [$0.year, $0.genre, $0.runtime].joined(separator: " • ") }
        
        let rate = basicInfo
            .map { "⭐ " + String($0.rating * 0.5) }
        
        let plot = basicInfo
            .map { $0.plot }
        
        let ratingObservable = input.viewWillAppear
            .withUnretained(self)
            .flatMap { (self, _) -> Observable<Double> in
                return self.useCase.getMovieRating(of: self.movieID)
            }
        
        let ratingDriver = input.tapRatingButton
            .skip(1)
            .withUnretained(self)
            .flatMapLatest { (self, rating) -> Observable<Bool> in
                return self.useCase.updateMovieRating(of: self.movieID, to: rating)
            }
            .asDriver(onErrorJustReturn: false)
        
        return Output(
            imageUrlObservable: imageUrl,
            titleObservable: title,
            descriptionObservable: description,
            rateObservable: rate,
            plotObservable: plot,
            reviewsObservable: reviewsObservable,
            ratingDriver: ratingDriver,
            ratingObservable: ratingObservable
        )
    }
    
    func toggle(with reviewID: MovieDetailReview.ID) {
        guard var selectedReview = reviews?.filter({ $0.id == reviewID }).first else {
            return
        }
        selectedReview.showAllContent.toggle()
        if let index = reviews?.firstIndex(where: { $0.id == reviewID }) {
            reviews?[index] = selectedReview
        }
    }
    
    func updateReviewState(with reviewID: MovieDetailReview.ID) {
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
