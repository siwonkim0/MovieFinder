//
//  AuthenticationViewModel.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/18.
//

import UIKit

final class AuthenticationViewModel {
    var token: String?
    
    private func getToken(completion: @escaping (Result<String, Error>) -> Void) {
        let url = URLManager.token.url
        APIManager.shared.getData(from: url, format: Token.self) { result in
            switch result {
            case .success(let movieToken):
                self.token = movieToken.requestToken
                completion(.success(movieToken.requestToken))
            case .failure(let error):
                if let error = error as? URLSessionError {
                    print(error.errorDescription)
                }
                if let error = error as? JSONError {
                    print("data decode failure: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func directToSignUpPage() {
        getToken { result in
            switch result {
            case .success(let token):
                guard let url = URLManager.signUp(token: token).url else {
                    return
                }
                if UIApplication.shared.canOpenURL(url) {
                    DispatchQueue.main.async {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            case .failure(let error):
                if let error = error as? URLSessionError {
                    print(error.errorDescription)
                }
                if let error = error as? JSONError {
                    print("data decode failure: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func createSessionIdWithToken(completion: @escaping (Result<Session, Error>) -> Void) {
        guard let token = token else {
            return
        }
        let requestToken = RequestToken(requestToken: token)
        let jsonData = JSONParser.encodeToData(with: requestToken)
        
        guard let sessionUrl = URLManager.session.url else {
            return
        }
        APIManager.shared.postData(jsonData, to: sessionUrl, format: Session.self, completion: completion)
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
    
    func saveSessionID() {
        createSessionIdWithToken { result in
            switch result {
            case .success(let session):
                guard let sessionID = session.sessionID,
                      let dataSessionID = sessionID.data(
                        using: String.Encoding.utf8,
                        allowLossyConversion: false) else {
                    return
                }
                self.saveToKeychain(dataSessionID)
            case .failure(let error):
                if let error = error as? URLSessionError {
                    print(error.errorDescription)
                }
                if let error = error as? JSONError {
                    print("data decode failure: \(error.localizedDescription)")
                }
            }
        }
    }
}
