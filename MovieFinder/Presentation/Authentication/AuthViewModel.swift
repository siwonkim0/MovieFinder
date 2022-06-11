//
//  AuthenticationViewModel.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/18.
//

import UIKit

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

final class AuthViewModel {
    let apiManager = APIManager()
    var token: String?
    
    private func getToken() async throws -> String {
        let url = MovieURL.token.url
        let movieToken = try await apiManager.getData(from: url, format: Token.self)
        self.token = movieToken.requestToken
        return movieToken.requestToken
    }
    
    func directToSignUpPage() async {
        do {
            let token = try await getToken()
            guard let url = MovieURL.signUp(token: token).url else {
                return
            }
            if await UIApplication.shared.canOpenURL(url) {
                DispatchQueue.main.async {
                    UIApplication.shared.open(url, options: [:])
                }
            }
        } catch(let error) {
            print(error.localizedDescription)
        }
    }
    
    private func createSessionIdWithToken() async throws -> Session {
        guard let token = token else {
            throw AuthError.invalidToken
        }
        let requestToken = RequestToken(requestToken: token)
        let jsonData = JSONParser.encodeToData(with: requestToken)
        
        guard let sessionUrl = MovieURL.session.url else {
            throw URLSessionError.invaildURL
        }
        return try await apiManager.postDataWithDecodingResult(jsonData, to: sessionUrl, format: Session.self)
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
    
    func saveSessionID() async {
        do {
            let session = try await createSessionIdWithToken()
            guard let sessionID = session.sessionID,
                  let dataSessionID = sessionID.data(
                    using: String.Encoding.utf8,
                    allowLossyConversion: false) else {
                throw AuthError.invalidSession
            }
            self.saveToKeychain(dataSessionID)
        } catch(let error) {
            print(error.localizedDescription)
        }
        
    }
}
