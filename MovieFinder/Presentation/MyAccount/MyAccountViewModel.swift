//
//  MyAccountViewModel.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/19.
//

import Foundation

final class MyAccountViewModel {
    let apiManager = URLSessionManager()
    
//    func getAccountDetails(sessionID: String) {
//        let url = MovieURL.accountDetail(sessionID: sessionID).url
//        apiManager.getData(from: url, format: AccountDetailDTO.self) { result in
//            switch result {
//            case .success(let account):
//                print(account.name)
//                print(account.username)
//            case .failure(let error):
//                if let error = error as? URLSessionError {
//                    print(error.errorDescription)
//                }
//
//                if let error = error as? JSONError {
//                    print("data decode failure: \(error.localizedDescription)")
//                }
//            }
//        }
//    }
}
