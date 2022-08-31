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
        let viewWillAppear: Observable<Void>
        let searchBarText: Observable<String>
        let searchCancelled: Observable<Void>
        let loadMoreContent: Observable<Bool>
    }
    
    struct Output {
        let searchResults: Driver<[SearchCellViewModel]>
    }
    
    let apiManager = URLSessionManager()
    let useCase: MoviesUseCase
    
    var searchText = BehaviorRelay<String>(value: "")
    var searchResults = BehaviorRelay<[SearchCellViewModel]>(value: [])
    var page: Int = 1
    var canLoadNextPage = false
    let disposeBag = DisposeBag()
    
    init(useCase: MoviesUseCase) {
        self.useCase = useCase
    }

    func transform(_ input: Input) -> Output {
        input.searchBarText
            .skip(1)
            .filter { $0.count > 0 }
            .withUnretained(self)
            .flatMapLatest { (self, keyword) in
                return self.useCase.getSearchResults(with: keyword, page: 1)
                    .withUnretained(self)
                    .map { (self, movieList) -> [SearchCellViewModel] in
                        self.page = movieList.page
                        self.searchText.accept(keyword)
                        self.canLoadNextPage = true
                        return movieList.items.filter { $0.posterPath != "" }
                            .map { SearchCellViewModel(movie: $0) }
                    }
            }
            .subscribe(with: self, onNext: { _, result in
                self.searchResults.accept(result)
            })
            .disposed(by: self.disposeBag)
        
        input.searchCancelled
            .subscribe(with: self, onNext: { _,_ in
                self.searchResults.accept([])
                self.canLoadNextPage = false
            })
            .disposed(by: self.disposeBag)
        
        input.loadMoreContent
            .withUnretained(self)
            .skip(3)
            .throttle(.seconds(3), latest: false, scheduler: MainScheduler.instance)
            .flatMapLatest { (self, _) -> Observable<[SearchCellViewModel]> in
                return self.useCase.getSearchResults(with: self.searchText.value, page: self.page)
                    .withUnretained(self)
                    .map { (self, movieList) -> [SearchCellViewModel] in
                        self.page = movieList.page + 1
                        return movieList.items.filter { $0.posterPath != "" }
                            .map { SearchCellViewModel(movie: $0) }
                    }
            }
            .subscribe(with: self, onNext: { _, newContents in
                if self.canLoadNextPage {
                    let oldContents = self.searchResults.value
                    self.searchResults.accept(oldContents + newContents)
                }
            })
            .disposed(by: self.disposeBag)
        return Output(
            searchResults: searchResults.asDriver()
        )
    }
    
}
