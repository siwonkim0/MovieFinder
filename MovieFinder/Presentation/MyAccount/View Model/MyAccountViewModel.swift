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
        let ratingDone: Signal<Bool>
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
                //최신이 위에나오게 하기
            }
            .asDriver(onErrorJustReturn: [])
        
        let updateRating = input.tapRatingButton
            .skip(1)
            .withUnretained(self)
            .flatMapLatest { (self, movie) -> Observable<Bool> in
                return self.useCase.updateMovieRating(of: movie.movieId, to: movie.rating)
            }
            .asSignal(onErrorJustReturn: false)
        
        return Output(
            ratingList: ratingList,
            ratingDone: updateRating
        )
    }

}
