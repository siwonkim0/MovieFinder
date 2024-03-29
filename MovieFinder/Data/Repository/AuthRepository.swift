//
//  AuthRepository.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/06/19.
//

import Foundation
import RxSwift

final class AuthRepository: MovieAuthRepository {
    private let urlSessionManager: URLSessionManager
    var token: String?
    
    init(urlSessionManager: URLSessionManager) {
        self.urlSessionManager = urlSessionManager
    }
    
    func makeUrlWithToken() -> Observable<URL> {
        let tokenRequest = TokenRequest()
        return urlSessionManager.performDataTask(with: tokenRequest)
            .withUnretained(self)
            .map { (self, movieToken) -> String in
                self.token = movieToken.requestToken
                return movieToken.requestToken
            }
            .compactMap { token in
                let url = SignUpRequest(urlPath: "authenticate/\(token)").urlComponents
                return url
            }
    }
    
    func createSessionIdWithToken() -> Observable<Void> {
        guard let token = self.token else {
            return .empty()
        }
        let requestToken = RequestToken(requestToken: token)
        let tokenData = JSONParser.encodeToData(with: requestToken)
        
        let sessionRequest = SessionRequest(httpBody: tokenData)
        return urlSessionManager.performDataTask(with: sessionRequest)
            .withUnretained(self)
            .map { (self, session) in
                guard let sessionID = session.sessionID,
                      let dataSessionID = sessionID.data(
                        using: String.Encoding.utf8,
                        allowLossyConversion: false) else {
                    return
                }
                try self.saveSessionIDToKeychain(dataSessionID)
            }
    }
    
    private func saveSessionIDToKeychain(_ dataSessionID: Data) throws {
        try KeychainManager.shared.save(
            data: dataSessionID,
            service: "TMDB",
            account: "access token"
        )
        KeychainManager.shared.isSessionIdExisting = true
    }
    
}
