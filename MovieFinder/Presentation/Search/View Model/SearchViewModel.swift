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
        let searchResultObservable: Observable<[MovieListItem]>
        let searchCancelledObservable: Observable<[MovieListItem]>
    }
    
    let apiManager = URLSessionManager()
    let rep = DefaultMoviesRepository(urlSessionManager: URLSessionManager())
    
    func transform(_ input: Input) -> Output {
        let searchResult = input.searchBarText
            .skip(1)
            .filter { $0.count > 0 }
            .withUnretained(self)
            .flatMapLatest { (self, keyword) in
                return self.rep.getSearchMovieList(with: keyword)
                    .filterErrors()
            }
        let cancelButton = input.searchCancelled
            .withUnretained(self)
            .flatMapLatest { (self, _) in
                return self.rep.getSearchMovieList(with: "sdsdsd")
                    .filterErrors()
            }
        return Output(searchResultObservable: searchResult, searchCancelledObservable: cancelButton)
    }
    
}
