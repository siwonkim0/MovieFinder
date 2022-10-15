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
            return setInitialDataMutation()
        case let .rate(movie):
            return rateMovieMutation(with: movie)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .fetchRatedMovies(results):
            newState.movies = results
            return newState
        case let .updateRating(ratedMovie):
            newState.ratedMovie = ratedMovie
            return newState
        }
    }
    
    private func setInitialDataMutation() -> Observable<Mutation> {
        return self.useCase.getTotalRatedList()
            .map { Mutation.fetchRatedMovies($0) }
    }
    
    private func rateMovieMutation(with movie: RatedMovie) -> Observable<Mutation> {
        return self.useCase.updateMovieRating(of: movie.movieId, to: movie.rating)
            .map { Mutation.updateRating($0) }
    }
    
}
