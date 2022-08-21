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
    
    init(authRepository: MovieAuthRepository, accountRepository: MovieAccountRepository) {
        self.authRepository = authRepository
        self.accountRepository = accountRepository
    }
    
    func getUrlWithToken() -> Observable<URL> {
        return authRepository.makeUrlWithToken()
    }
    
    func createSessionIdWithToken() -> Observable<Void> {
        return authRepository.createSessionIdWithToken()
    }
    
    func getAccountID() -> Observable<Data> {
        return accountRepository.getAccountID()
    }
}
