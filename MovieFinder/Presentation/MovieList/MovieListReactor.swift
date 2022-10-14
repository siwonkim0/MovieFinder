//
//  MovieListReactor.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/10/12.
//

import Foundation
import ReactorKit

class MovieListReactor: Reactor {
    var initialState: State = State()
    private let useCase: MoviesUseCase
    
    init(useCase: MoviesUseCase) {
        self.useCase = useCase
    }
    
    enum Action {
        case setInitialResults
        case refresh
    }
    
    enum Mutation {
        case fetchMovieListResults([Section])
        case setIsLoading(Bool)
    }
    
    struct State {
        var movieResults: [Section] = []
        var isLoading: Bool = false
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .setInitialResults:
            return getMovieLists()
                    .map { Mutation.fetchMovieListResults($0) }
        case .refresh:
            return Observable.concat([
                Observable.just(Mutation.setIsLoading(true)),
                getMovieLists()
                        .map { Mutation.fetchMovieListResults($0) },
                Observable.just(Mutation.setIsLoading(false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        switch mutation {
        case let .fetchMovieListResults(results):
            var newState = state
            newState.movieResults = results
            return newState
        case let .setIsLoading(isLoading):
            var newState = state
            newState.isLoading = isLoading
            return newState
        }
    }
    
    private func getMovieLists() -> Observable<[Section]> {
        useCase.getMovieLists()
            .map { lists in
                lists.map { list in
                    list.items.map { movie in
                        MovieListCellViewModel(movie: movie, section: list.section!)
                    }
                }
            }
            .map { items in
                return items.map { items -> Section in
                    let title = items.map({$0.section.title}).first ?? ""
                    return Section(title: title, movies: items)
                }
            }
    }
    
    
}