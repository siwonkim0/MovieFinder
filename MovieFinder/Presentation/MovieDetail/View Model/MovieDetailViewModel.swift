//
//  MovieDetailViewModel.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/19.
//

import Foundation
import RxSwift

final class MovieDetailViewModel: ViewModelType {
    struct Input {
        let viewWillAppear: Observable<Void>
    }
    
    struct Output {
//        let basicInfoObservable: Observable<MovieDetailBasicInfo>
        let reviewsObservable: Observable<[MovieDetailReview]>
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
        
        return Output(reviewsObservable: reviewsObservable)
    }
    
    func getBasicDetails() {
        let movieDetailItem = useCase.getMovieDetailItem(from: movieID)
        movieDetailItem.subscribe(onNext: { detail in
            print(detail)
        })
    }
    
}
