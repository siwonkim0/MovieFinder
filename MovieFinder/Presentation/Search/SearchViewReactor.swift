//
//  SearchViewReactor.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/10/11.
//

import Foundation
import ReactorKit

class SearchViewReactor: Reactor {
    var initialState: State = State()
    private let useCase: MoviesUseCase
    
    init(useCase: MoviesUseCase) {
        self.useCase = useCase
    }
    
    enum Action {
        case searchKeyword(String)
        case loadNextPage
        case clearSearchKeyword
    }
    
    enum Mutation {
        case setKeyword(String)
        case fetchNewMovieResults([SearchCellViewModel], nextPage: Int)
        case fetchNextPageMovieResults([SearchCellViewModel], nextPage: Int?) //nextPage += 1
        case setLoadingNextPage(Bool)
        case clearMovieResults
    }
    
    struct State {
        var keyword: String = ""
        var movieResults: [SearchCellViewModel] = []
        var nextPage: Int? = 1
        var isLoadingNextPage: Bool = false
        var isLastPage: Bool = false
    }
    
    //action에 대한 처리
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .searchKeyword(let keyword): //새로운 키워드가 들어오면
            return searchKeywordMutation(with: keyword)
        case .loadNextPage:
            guard let page = currentState.nextPage else {
                return .empty()
            }
            let keyword = currentState.keyword
            let isLoadingNextPage = currentState.isLoadingNextPage

            guard !isLoadingNextPage else {
                return .empty()
            }
            return loadNextPageMutation(with: keyword, page: page)
        case .clearSearchKeyword:
            return clearSearchKeywordMutation()
        }
    }
    
    //이전 상태와 처리를 받아서 다음 상태 반환
    func reduce(state: State, mutation: Mutation) -> State {
        switch mutation {
        case let .setKeyword(keyword): //응 키워드 상태 변경할게
            var newState = state
            newState.keyword = keyword
            return newState
        case let .fetchNewMovieResults(items, nextPage):
            var newState = state
            newState.movieResults = items
            newState.nextPage = nextPage
            return newState
        case let .fetchNextPageMovieResults(items, nextPage):
            var newState = state
            newState.movieResults.append(contentsOf: items)
            newState.nextPage = nextPage
            return newState
        case let .setLoadingNextPage(isLoadingNextPage):
            var newState = state
            newState.isLoadingNextPage = isLoadingNextPage
            return newState
        case .clearMovieResults:
            var newState = state
            newState.movieResults = []
            return newState
        }
    }
    
    private func searchKeywordMutation(with keyword: String) -> Observable<Mutation> {
        return Observable.concat([
            Observable.just(Mutation.setKeyword(keyword)), //키워드 상태 변경해
            self.useCase.getSearchResults(with: keyword, page: 1) //결과 상태 변경해
                .flatMap { movieList -> Observable<Mutation> in
                    let items = movieList.items.filter { $0.posterPath != "" }
                        .map { SearchCellViewModel(movie: $0) }
                    let nextPage = movieList.page + 1
                    return .just(Mutation.fetchNewMovieResults(items, nextPage: nextPage))
                }
        ])
    }
    
    private func loadNextPageMutation(with keyword: String, page: Int) -> Observable<Mutation> {
        return Observable.concat([
            Observable.just(Mutation.setLoadingNextPage(true)),
            self.useCase.getSearchResults(with: keyword, page: page)
                .flatMap { movieList -> Observable<Mutation> in
                    let items = movieList.items.filter { $0.posterPath != "" }
                        .map { SearchCellViewModel(movie: $0) }
                    guard let nextPage = movieList.nextPage else {
                        return .empty()
                    }
                    return .just(Mutation.fetchNextPageMovieResults(items, nextPage: nextPage))
                },
            Observable.just(Mutation.setLoadingNextPage(false))
        ])
    }
    
    private func clearSearchKeywordMutation() -> Observable<Mutation> {
        return Observable.concat([
            Observable.just(Mutation.setKeyword("")),
            Observable.just(Mutation.clearMovieResults)
        ])
    }
    
}
