//
//  SearchViewModel.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/19.
//

import Foundation
import RxSwift
import RxCocoa

final class SearchViewModel {
    struct Input {
        let searchBarText: Observable<String>
        let searchCancelled: Observable<Void>
        let loadMoreContent: Observable<Void>
    }
    
    struct Output {
        let newSearchResults: Signal<[SearchCellViewModel]>
        let cancelResults: Signal<[SearchCellViewModel]>
        let moreResults: Signal<[SearchCellViewModel]>
    }
    
    private var searchText: String = ""
    private var page: Int = 1
    private var searchResults = [SearchCellViewModel]()
    private let useCase: MoviesUseCase
    
    init(useCase: MoviesUseCase) {
        self.useCase = useCase
    }

    func transform(_ input: Input) -> Output {
        let newSearchResults = input.searchBarText
            .filter { $0.count > 0 }
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
//            .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .flatMapLatest { keyword in
                return self.useCase.getSearchResults(with: keyword, page: 1)
                    .map { movieList -> [SearchCellViewModel] in
                        self.searchText = keyword
                        self.page = movieList.page
                        return movieList.items.filter { $0.posterPath != "" }
                            .map { SearchCellViewModel(movie: $0) }
                    }
                    .map { result -> [SearchCellViewModel] in
                        self.searchResults = result
                        return self.searchResults
                    }
            }
            .asSignal(onErrorJustReturn: [])

        
        let cancelResults = input.searchCancelled
            .map { _ -> [SearchCellViewModel] in
                self.searchResults = []
                return self.searchResults
            }
            .asSignal(onErrorJustReturn: [])
        
        let moreResults = input.loadMoreContent
            .flatMapLatest { _ -> Observable<[SearchCellViewModel]> in
                return self.useCase.getSearchResults(with: self.searchText, page: self.page)
                    .map { (movieList) -> [SearchCellViewModel] in
                        self.page = movieList.page + 1
                        return movieList.items.filter { $0.posterPath != "" }
                            .map { SearchCellViewModel(movie: $0) }
                    }
            }
            .map { (newContents) -> [SearchCellViewModel] in
                let oldContents = self.searchResults
                self.searchResults = oldContents + newContents
                return self.searchResults
            }
            .asSignal(onErrorJustReturn: [])
    
        return Output(
            newSearchResults: newSearchResults,
            cancelResults: cancelResults,
            moreResults: moreResults
        )
    }
    
}