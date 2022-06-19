//
//  AuthRepository.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/06/19.
//

import Foundation
import RxSwift

protocol MovieAuthRepository {
    func getToken(from url: URL?) -> Observable<Token>
    func createSession(with token: Data?, to url: URL?, format: Session.Type) -> Observable<Session>
}

class AuthRepository: MovieAuthRepository {
    let apiManager: APIManager
    
    init(apiManager: APIManager) {
        self.apiManager = apiManager
    }
    
    func getToken(from url: URL?) -> Observable<Token> {
        return apiManager.getData(from: url, format: Token.self)
    }
    
    func createSession(with token: Data?, to url: URL?, format: Session.Type) -> Observable<Session> {
        return apiManager.postData(token, to: url, format: Session.self)
    }
}
