//
//  MyAccountViewModel.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/19.
//

import Foundation
import RxSwift
import RxCocoa

final class MyAccountViewModel: ViewModelType {
    struct Input {
        let viewWillAppear: Observable<Void>
        let tapRatingButton: Observable<RatedMovie>
    }
    
    struct Output {
        let ratingList: Driver<[MovieListItem]>
        let ratingDone: Signal<RatedMovie>
    }
    
    private let useCase: MoviesAccountUseCase
    
    init(useCase: MoviesAccountUseCase) {
        self.useCase = useCase
    }
    
    func transform(_ input: Input) -> Output {
        let ratingList = input.viewWillAppear
            .withUnretained(self)
            .flatMap { (self, _) in
                return self.useCase.getTotalRatedList()
            }
            .asDriver(onErrorJustReturn: [])
        
        let updateRating = input.tapRatingButton
            .withUnretained(self)
            .flatMapLatest { (self, ratedMovie) -> Observable<RatedMovie> in
                return self.useCase.updateMovieRating(of: ratedMovie.movieId, to: ratedMovie.rating)
            }
            .asSignal(onErrorJustReturn: RatedMovie(movieId: 0, rating: 0))
        
        return Output(
            ratingList: ratingList,
            ratingDone: updateRating
        )
    }

}
