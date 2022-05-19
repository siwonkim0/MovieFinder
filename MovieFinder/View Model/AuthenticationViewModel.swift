//
//  AuthenticationViewModel.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/18.
//

import UIKit

final class AuthenticationViewModel {
    func getToken() {
        APIManager.shared.getToken { result in
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
    
    func createSessionID() {
        APIManager.shared.createSessionID { result in
            switch result {
            case .success(let session):
                guard let sessionID = session.sessionID else {
                    return
                }
                guard let dataSessionID = sessionID.data(
                    using: String.Encoding.utf8,
                    allowLossyConversion: false
                ) else {
                    return
                }
                
                do {
                    try KeychainManager.shared.save(
                        data: dataSessionID,
                        service: "TMDB",
                        account: "access token"
                    )
                } catch {
                    print("Failed to save Session ID")
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
}
