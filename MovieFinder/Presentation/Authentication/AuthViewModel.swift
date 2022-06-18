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
    }
    
    struct Output {
        let tokenUrl: Observable<URL>
        let didCreateAccount: Observable<Void>
    }
    
    let disposeBag = DisposeBag()
    let repository: AuthRepository
    var token: String?
    
    init(repository: AuthRepository) {
        self.repository = repository
    }
    
    func transform(_ input: Input) -> Output {
        let url = input.didTapOpenUrlWithToken
            .flatMap { _ in
                return self.signUpPageUrl()
            }
        
        let authDone = input.didTapAuthDone
            .flatMap {
                self.createSessionIdWithToken()
            }
            .map { session in
                    guard let sessionID = session.sessionID,
                          let dataSessionID = sessionID.data(
                            using: String.Encoding.utf8,
                            allowLossyConversion: false) else {
                        return
                    }
                    self.saveToKeychain(dataSessionID)
            }
        
        return Output(tokenUrl: url, didCreateAccount: authDone)
    }
    
    private func getToken() -> Observable<String> {
        let url = MovieURL.token.url
        let movieToken = repository.getToken(from: url)
        
        return movieToken
            .map { movieToken in
                self.token = movieToken.requestToken
                return movieToken.requestToken
            }
    }
    
    private func signUpPageUrl() -> Observable<URL> {
        return getToken()
            .compactMap { token in
                let url = MovieURL.signUp(token: token).url
                return url
            }
    }
    
    private func createSessionIdWithToken() -> Observable<Session> {
        guard let token = self.token else {
            return .empty()
        }
        let requestToken = RequestToken(requestToken: token)
        let jsonData = JSONParser.encodeToData(with: requestToken)
        
        guard let sessionUrl = MovieURL.session.url else {
            return .empty()
        }
        return repository.createSession(with: jsonData, to: sessionUrl, format: Session.self)
    }
    
    private func saveToKeychain(_ dataSessionID: Data) {
        do {
            try KeychainManager.shared.save(
                data: dataSessionID,
                service: "TMDB",
                account: "access token"
            )
        } catch {
            print("Failed to save Session ID")
        }
    }
    
}
