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
        let basicInfoObservable: Observable<MovieDetailBasicInfo>
        let reviewsObservable: Observable<[MovieDetailReview]>
        let ratingDriver: Driver<Bool>
        let ratingObservable: Observable<Double>
    }
    
    private let movieID: Int
    private let useCase: DefaultMoviesUseCase
    
    
    init(movieID: Int, useCase: DefaultMoviesUseCase) {
        self.movieID = movieID
        self.useCase = useCase
    }
    
    func transform(_ input: Input) -> Output {
        let reviewsObservable = input.viewWillAppear
            .withUnretained(self)
            .flatMap { (self, _) in
                return self.useCase.getMovieDetailReviews(from: self.movieID)
            }
        let basicInfoObservable = input.viewWillAppear
            .withUnretained(self)
            .flatMap { (self, _) in
                return self.useCase.getMovieDetailItem(from: self.movieID)
            }
        
        let ratingObservable = input.viewWillAppear
            .withUnretained(self)
            .flatMap { (self, _) in
                return self.useCase.getMovieRating(of: self.movieID)
            }
        
        let ratingDriver = input.tapRatingButton
            .skip(1)
            .withUnretained(self)
            .flatMapLatest { (self, rating) in
                self.useCase.updateMovieRating(of: self.movieID, to: rating)
            }
            .asDriver(onErrorJustReturn: false)
        
        return Output(
            basicInfoObservable: basicInfoObservable,
            reviewsObservable: reviewsObservable,
            ratingDriver: ratingDriver,
            ratingObservable: ratingObservable
        )
    }
    
    
}
