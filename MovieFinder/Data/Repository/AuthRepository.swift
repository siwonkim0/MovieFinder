//
//  AuthRepository.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/06/19.
//

import Foundation
import RxSwift

class AuthRepository: MovieAuthRepository {
    let apiManager: APIManager
    
    init(apiManager: APIManager) {
        self.apiManager = apiManager
    }
    
    func getToken(from url: URL?) -> Observable<Token> {
        return apiManager.getData(from: url, format: Token.self)
    }
    
    func createSession(with token: Data?, to url: URL?, format: Session.Type) -> Observable<Void> {
        return apiManager.postData(token, to: url, format: Session.self)
            .map { session in
                guard let sessionID = session.sessionID,
                      let dataSessionID = sessionID.data(
                        using: String.Encoding.utf8,
                        allowLossyConversion: false) else {
                    return
                }
                self.saveSessionIDToKeychain(dataSessionID)
            }
    }
    
    private func saveSessionIDToKeychain(_ dataSessionID: Data) {
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
