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
            return "invalidToken"
        case .invalidSession:
            return "invalidSession"
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
    
    let authRepository: MovieAuthRepository
    let accountRepository: MovieAccountRepository
    var token: String?
    
    init(authRepository: MovieAuthRepository, accountRepository: MovieAccountRepository) {
        self.authRepository = authRepository
        self.accountRepository = accountRepository
    }
    
    func transform(_ input: Input) -> Output {
        let url = input.didTapOpenUrlWithToken
            .flatMap { _ in
                return self.directToSignUpPage()
            }
        
        let authDone = input.didTapAuthDone
            .flatMap {
                self.createSessionIdWithToken()
            }
            
        let accountSaved = input.viewWillDisappear
            .flatMap {
                self.accountRepository.getAccountID()
            }
        return Output(tokenUrl: url, didCreateAccount: authDone, didSaveAccountID: accountSaved)
    }
    
    private func directToSignUpPage() -> Observable<URL> {
        return getToken()
            .compactMap { token in
                let url = MovieURL.signUp(token: token).url
                return url
            }
    }
    
    private func getToken() -> Observable<String> {
        let url = MovieURL.token.url
        let movieToken = authRepository.getToken(from: url)
        
        return movieToken
            .map { movieToken in
                self.token = movieToken.requestToken
                return movieToken.requestToken
            }
    }
    
    private func createSessionIdWithToken() -> Observable<Void> {
        guard let token = self.token else {
            return .empty()
        }
        let requestToken = RequestToken(requestToken: token)
        let tokenData = JSONParser.encodeToData(with: requestToken)
        
        guard let sessionUrl = MovieURL.session.url else {
            return .empty()
        }
        return authRepository.createSession(with: tokenData, to: sessionUrl, format: Session.self)
    }
}
