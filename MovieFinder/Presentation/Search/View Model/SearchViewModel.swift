//
//  SearchViewModel.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/19.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa

final class SearchViewModel {
    struct Input {
        let searchBarText: Observable<String>
        let searchCancelled: Observable<Void>
        let loadMoreContent: Observable<Bool>
    }
    
    struct Output {
        let newSearchResults: Driver<[SearchCellViewModel]>
        let cancelResults: Driver<[SearchCellViewModel]>
        let moreResults: Driver<[SearchCellViewModel]>
    }
    
    private var searchText: String = ""
    private var page: Int = 1
    private var searchResults = [SearchCellViewModel]()
    private let disposeBag = DisposeBag()
    private let useCase: MoviesUseCase
    
    init(useCase: MoviesUseCase) {
        self.useCase = useCase
    }

    func transform(_ input: Input) -> Output {
        let newSearchResults = input.searchBarText
            .skip(1)
            .filter { $0.count > 0 }
            .withUnretained(self)
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .flatMapLatest { (self, keyword) in
                return self.useCase.getSearchResults(with: keyword, page: 1)
                    .map { (movieList) -> [SearchCellViewModel] in
                        self.searchText = keyword
                        self.page = movieList.page
                        return movieList.items.filter { $0.posterPath != "" }
                            .map { SearchCellViewModel(movie: $0) }
                    }
                    .withUnretained(self)
                    .map { (self, result) -> [SearchCellViewModel] in
                        self.searchResults = result
                        return self.searchResults
                    }
            }
            .asDriver(onErrorJustReturn: [])

        
        let cancelResults = input.searchCancelled
            .withUnretained(self)
            .map { (self, _) -> [SearchCellViewModel] in
                self.searchResults = []
                return self.searchResults
            }
            .asDriver(onErrorJustReturn: [])
        
        let moreResults = input.loadMoreContent
            .withUnretained(self)
            .skip(3)
            .flatMapLatest { (self, _) -> Observable<[SearchCellViewModel]> in
                return self.useCase.getSearchResults(with: self.searchText, page: self.page)
                    .withUnretained(self)
                    .map { (self, movieList) -> [SearchCellViewModel] in
                        self.page = movieList.page + 1
                        return movieList.items.filter { $0.posterPath != "" }
                            .map { SearchCellViewModel(movie: $0) }
                    }
            }
            .withUnretained(self)
            .map { (self, newContents) -> [SearchCellViewModel] in
                let oldContents = self.searchResults
                self.searchResults = oldContents + newContents
                return self.searchResults
            }
            .asDriver(onErrorJustReturn: [])
    
        return Output(
            newSearchResults: newSearchResults,
            cancelResults: cancelResults,
            moreResults: moreResults
        )
    }
    
}
