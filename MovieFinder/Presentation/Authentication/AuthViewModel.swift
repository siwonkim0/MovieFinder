//
//  AuthenticationViewModel.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/18.
//

import UIKit
import RxSwift

enum AuthError: Error {
    case invalidToken
    case invalidSession
    
    var errorDescription: String {
        switch self {
        case .invalidToken:
            return "invalid token"
        case .invalidSession:
            return "invalid session"
        }
    }
}

final class AuthViewModel: ViewModelType {
    struct Input {
        let didTapOpenUrlWithToken: Observable<Void>
        let sceneWillEnterForeground: Observable<Void>
    }
    
    struct Output {
        let tokenUrl: Observable<URL>
        let didSaveSessionId: Observable<Data>
    }
    
    let useCase: MoviesAuthUseCase
    
    init(useCase: MoviesAuthUseCase) {
        self.useCase = useCase
    }
    
    func transform(_ input: Input) -> Output {
        let url = input.didTapOpenUrlWithToken
            .withUnretained(self)
            .flatMap { (self, _) in
                self.useCase.getUrlWithToken()
            }
        let sceneWillEnterForeground = input.sceneWillEnterForeground
            .withUnretained(self)
            .flatMap { (self, _) in
                self.useCase.createSessionIdWithToken()
            }
            .withUnretained(self)
            .flatMap { (self, _) in
                self.useCase.saveAccountId()
            }
        
        return Output(
            tokenUrl: url,
            didSaveSessionId: sceneWillEnterForeground
        )
    }

}
