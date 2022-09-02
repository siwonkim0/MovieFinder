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
        let searchResults: Driver<[SearchCellViewModel]>
    }
    
    private var searchText: String = ""
    private var page: Int = 1
    private var searchResults = BehaviorRelay<[SearchCellViewModel]>(value: [])
    private let disposeBag = DisposeBag()
    private let useCase: MoviesUseCase
    
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
                    .map { (movieList) -> [SearchCellViewModel] in
                        self.searchText = keyword
                        self.page = movieList.page
                        return movieList.items.filter { $0.posterPath != "" }
                            .map { SearchCellViewModel(movie: $0) }
                    }
            }
//            .subscribe(with: self, onNext: { _, result in
//                self.searchResults.accept(result)
//            })
//            .disposed(by: self.disposeBag)
            .bind(to: self.searchResults)
            .disposed(by: disposeBag)
        
        input.searchCancelled
            .subscribe(with: self, onNext: { _,_ in
                self.searchResults.accept([])
            })
            .disposed(by: self.disposeBag)
        
        input.loadMoreContent
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
            .subscribe(with: self, onNext: { _, newContents in
                    let oldContents = self.searchResults.value
                    self.searchResults.accept(oldContents + newContents)
            })
            .disposed(by: self.disposeBag)
        return Output(
            searchResults: searchResults.asDriver()
        )
    }
    
}
