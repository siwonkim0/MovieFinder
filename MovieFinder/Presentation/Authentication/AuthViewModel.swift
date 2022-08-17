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
        let didTapAuthDone: Observable<Void>
        let viewWillDisappear: Observable<Void>
    }
    
    struct Output {
        let tokenUrl: Observable<URL>
        let didCreateAccount: Observable<Void>
        let didSaveAccountID: Observable<Data>
    }
    
    let useCase: MoviesAuthUseCase
    
    init(useCase: MoviesAuthUseCase) {
        self.useCase = useCase
    }
    
    func transform(_ input: Input) -> Output {
        let url = input.didTapOpenUrlWithToken
            .flatMap { _ in
                self.useCase.getUrlWithToken()
            }
        
        let authDone = input.didTapAuthDone
            .flatMap {
                self.useCase.createSessionIdWithToken()
            }
            
        let accountSaved = input.viewWillDisappear
            .flatMap {
                self.useCase.getAccountID()
            }
        return Output(tokenUrl: url, didCreateAccount: authDone, didSaveAccountID: accountSaved)
    }
    

}
