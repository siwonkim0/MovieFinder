//
//  AuthReactor.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/10/13.
//

import Foundation
import ReactorKit

class AuthReactor: Reactor {
    var initialState: State = State()
    private let useCase: MoviesAuthUseCase
    
    init(useCase: MoviesAuthUseCase) {
        self.useCase = useCase
    }
    
    enum Action {
        case openURL
        case authenticate
    }
    
    enum Mutation {
        case getURLWithToken(URL)
        case createSessionIdWithToken
        case saveAccountID
    }
    
    struct State {
        @Pulse var url: URL?
        var isAuthDone: Bool = false
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .openURL:
            return self.useCase.getUrlWithToken()
                .map { Mutation.getURLWithToken($0) }
        case .authenticate:
            return Observable.concat([
                useCase.createSessionIdWithToken().map { Mutation.createSessionIdWithToken },
                useCase.saveAccountId().map { _ in Mutation.saveAccountID }
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        switch mutation {
        case let .getURLWithToken(url):
            var newState = state
            newState.url = url
            return newState
        case .createSessionIdWithToken:
            var newState = state
            newState.isAuthDone.toggle()
            print(newState.isAuthDone)
            return newState
        case .saveAccountID:
            return state
        }
    }
    
}
