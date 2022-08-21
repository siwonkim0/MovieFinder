//
//  AccountRepository.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/08/13.
//

import Foundation
import RxSwift

final class AccountRepository: MovieAccountRepository {
    let urlSessionManager: URLSessionManager

    init(urlSessionManager: URLSessionManager) {
        self.urlSessionManager = urlSessionManager
    }

    func getAccountID() -> Observable<Data> {
        return urlSessionManager.getData(from: MovieURL.accountDetail(sessionID: KeychainManager.shared.getSessionID()).url, format: AccountDetailDTO.self).map { $0.id }
            .map { accountID in
                guard let dataSessionID = String(accountID).data(
                        using: String.Encoding.utf8,
                        allowLossyConversion: false) else {
                    return Data()
                }
                self.saveAccountIDToKeyChain(dataSessionID)
                return dataSessionID
            }
    }

    private func saveAccountIDToKeyChain(_ dataAccountID: Data) {
        do {
            try KeychainManager.shared.save(
                data: dataAccountID,
                service: "TMDB",
                account: "account ID"
            )
        } catch {
            print("Failed to save account ID")
        }
    }

}
