//
//  SearchViewModel.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/19.
//

import Foundation
import RxSwift
import RxRelay

final class SearchViewModel {
    struct Input {
        let viewWillAppear: Observable<Void>
        let searchBarText: Observable<String>
        let searchCancelled: Observable<Void>
        let loadMoreContent: Observable<CGFloat>
    }
    
    struct Output {
        let searchResultObservable: Observable<[SearchCellViewModel]>
        let searchCancelledObservable: Observable<[SearchCellViewModel]>
        let loadMoreContentObservable: Observable<[SearchCellViewModel]>
    }
    
    let apiManager = URLSessionManager()
    let useCase: MoviesUseCase
    var searchText: String = ""
    var searchResult: [SearchCellViewModel] = []
    var page: Int = 1
    
    init(useCase: MoviesUseCase) {
        self.useCase = useCase
    }
    
    func transform(_ input: Input) -> Output {
        let searchResult = input.searchBarText
            .skip(1)
            .filter { $0.count > 0 }
            .withUnretained(self)
            .flatMapLatest { (self, keyword) in
                return self.useCase.getSearchResults(with: keyword, page: 1)
                    .map { (aa) -> [SearchCellViewModel] in
                        self.searchText = keyword
                        return aa.filter { $0.posterPath != "" }
                            .map { SearchCellViewModel(movie: $0) }
                    }
                    .filterErrors()
            }
        let cancelButton = input.searchCancelled
            .withUnretained(self)
            .flatMapLatest { (self, _) in
                return self.useCase.getSearchResults(with: "sdsdsd", page: 1)
                    .map {
                        $0.filter { $0.posterPath != "" }
                            .map { SearchCellViewModel(movie: $0) }
                    }
                    .filterErrors()
            }
        let loadContent = input.loadMoreContent
            .withUnretained(self)
            .debug()
            .skip(3)
            .throttle(.seconds(3), latest: false, scheduler: MainScheduler.instance)
            .flatMap { (self, _) -> Observable<[SearchCellViewModel]> in
                self.page = self.page + 1
                return self.useCase.getSearchResults(with: self.searchText, page: self.page)
                    .map {
                        $0.filter { $0.posterPath != "" }
                            .map { SearchCellViewModel(movie: $0) }
                    }
                    .map { newContents -> [SearchCellViewModel] in
                        print(self.page)
                        self.searchResult.append(contentsOf: newContents)
                        return self.searchResult
                    }
                    .filterErrors()
            }
        
        return Output(
            searchResultObservable: searchResult,
            searchCancelledObservable: cancelButton,
            loadMoreContentObservable: loadContent
        )
    }
    
}
