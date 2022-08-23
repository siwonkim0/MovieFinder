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
//        let tapCancelButton: Observable<Void>
    }
    
    struct Output {
        let searchResultObservable: Observable<[MovieListItem]>
//        let cancelButtonObservable: Observable<[MovieListItem]>
    }
    
    let apiManager = URLSessionManager()
    let rep = DefaultMoviesRepository(urlSessionManager: URLSessionManager())
    
    func transform(_ input: Input) -> Output {
        let searchResult = input.searchBarText
            .skip(1)
            .withUnretained(self)
            .flatMapLatest { (self, keyword) in
                return self.rep.getSearchMovieList(with: keyword)
            }
//        let cancelButton = input.tapCancelButton
//            .skip(1)
//            .withUnretained(self)
//            .flatMap { (self, _) in
//                return
//            }
        
        return Output(searchResultObservable: searchResult)
    }
    
}
