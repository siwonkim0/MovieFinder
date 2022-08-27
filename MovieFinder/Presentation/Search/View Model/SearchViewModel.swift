//
//  SearchViewModel.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/19.
//

import Foundation
import RxSwift

final class SearchViewModel {
    struct Input {
        let viewWillAppear: Observable<Void>
        let searchBarText: Observable<String>
        let searchCancelled: Observable<Void>
    }
    
    struct Output {
        let searchResultObservable: Observable<[SearchCellViewModel]>
        let searchCancelledObservable: Observable<[SearchCellViewModel]>
    }
    
    let apiManager = URLSessionManager()
    let useCase: MoviesUseCase
    
    init(useCase: MoviesUseCase) {
        self.useCase = useCase
    }
    
    func transform(_ input: Input) -> Output {
        let searchResult = input.searchBarText
            .skip(1)
            .filter { $0.count > 0 }
            .withUnretained(self)
            .flatMapLatest { (self, keyword) in
                return self.useCase.getSearchResults(with: keyword)
                    .map {
                        $0.filter { $0.posterPath != "" }
                            .map { SearchCellViewModel(movie: $0) }
                    }
                    .filterErrors()
            }
        let cancelButton = input.searchCancelled
            .withUnretained(self)
            .flatMapLatest { (self, _) in
                return self.useCase.getSearchResults(with: "sdsdsd")
                    .map {
                        $0.filter { $0.posterPath != "" }
                            .map { SearchCellViewModel(movie: $0) }
                    }
                    .filterErrors()
            }
        return Output(searchResultObservable: searchResult, searchCancelledObservable: cancelButton)
    }
    
}
