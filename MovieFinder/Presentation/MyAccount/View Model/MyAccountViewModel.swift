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
    }
    
    struct Output {
        let ratingList: Driver<[MovieListItem]>
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
        
        return Output(
            ratingList: ratingList
        )
    }

}
