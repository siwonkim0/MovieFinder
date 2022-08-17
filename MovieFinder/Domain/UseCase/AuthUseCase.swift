//
//  AuthUseCase.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/08/14.
//

import Foundation
import RxSwift

protocol MoviesAuthUseCase {
    func getUrlWithToken() -> Observable<URL>
    func createSessionIdWithToken() -> Observable<Void>
    func getAccountID() -> Observable<Data>
}

final class AuthUseCase: MoviesAuthUseCase {
    let authRepository: MovieAuthRepository
    let accountRepository: MovieAccountRepository
    var token: String?
    
    init(authRepository: MovieAuthRepository, accountRepository: MovieAccountRepository) {
        self.authRepository = authRepository
        self.accountRepository = accountRepository
    }
    
    func getUrlWithToken() -> Observable<URL> {
        let url = MovieURL.token.url
        let movieToken = authRepository.getToken(from: url)
        
        return movieToken
            .withUnretained(self)
            .map { (self, movieToken) -> String in
                self.token = movieToken.requestToken
                return movieToken.requestToken
            }
            .withUnretained(self)
            .compactMap { (self, token) in
                let url = MovieURL.signUp(token: token).url
                return url
            }
    }
    
    func createSessionIdWithToken() -> Observable<Void> {
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
    
    func getAccountID() -> Observable<Data> {
        return accountRepository.getAccountID()
    }
}
