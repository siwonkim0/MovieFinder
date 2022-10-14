//
//  MyAccountReactor.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/10/13.
//

import Foundation
import ReactorKit

class MyAccountReactor: Reactor {
    var initialState: State = State()
    private let useCase: MoviesAccountUseCase
    
    init(useCase: MoviesAccountUseCase) {
        self.useCase = useCase
    }
    
    enum Action {
        case setInitialData
        case rate(RatedMovie)
    }
    
    enum Mutation {
        case fetchRatedMovies([MovieListItem])
        case updateRating(RatedMovie)
    }
    
    struct State {
        var movies: [MovieListItem] = []
        @Pulse var ratedMovie: RatedMovie?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .setInitialData:
            return self.useCase.getTotalRatedList()
                .map { Mutation.fetchRatedMovies($0) }
        case let .rate(ratedMovie):
            return self.useCase.updateMovieRating(of: ratedMovie.movieId, to: ratedMovie.rating)
                .map { Mutation.updateRating($0) }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        switch mutation {
        case let .fetchRatedMovies(results):
            var newState = state
            newState.movies = results
            return newState
        case let .updateRating(ratedMovie):
            var newState = state
            newState.ratedMovie = ratedMovie
            return newState
        }
    }
    
}