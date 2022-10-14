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
    }
    
    struct State {
        @Pulse var url: URL?
        @Pulse var isAuthDone: Bool = false
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .openURL:
            return getUrlMutation()
        case .authenticate:
            return authenticateMutation()
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
            return newState
        }
    }
    
    private func getUrlMutation() -> Observable<Mutation> {
        return self.useCase.getUrlWithToken().map { Mutation.getURLWithToken($0) }
    }
    
    private func authenticateMutation() -> Observable<Mutation> {
        return useCase.createSessionIdWithToken()
            .flatMap {
                self.useCase.saveAccountId()
            }
            .map { _ in Mutation.createSessionIdWithToken }
    }
    
}
