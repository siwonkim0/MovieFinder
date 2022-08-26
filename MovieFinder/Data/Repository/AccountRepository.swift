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
    
    func saveAccountId() -> Observable<Data> {
        let accountIdRequest = AccountIdRequest(
            queryParameters: ["api_key": ApiKey.tmdb.description,
                              "session_id": KeychainManager.shared.getSessionID()]
        )
        return urlSessionManager.performDataTask(with: accountIdRequest)
            .map { $0.id }
            .map { accountID in
                guard let dataSessionID = String(accountID).data(
                        using: String.Encoding.utf8,
                        allowLossyConversion: false) else {
                    return Data()
                }
                self.saveAccountIDToKeyChain(dataSessionID)
                print(dataSessionID)
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
    
    func updateMovieRating(of id: Int, to rating: Double) -> Observable<Bool> {
        let data = JSONParser.encodeToData(with: ["value": rating])
        let rateRequest = RateRequest(
            urlPath: "movie/\(id)/rating?",
            queryParameters: ["api_key": ApiKey.tmdb.description,
                              "session_id": KeychainManager.shared.getSessionID()],
            httpBody: data
        )
        return urlSessionManager.performDataTask(with: rateRequest)
            .map { respond in
                print(respond.success)
                return respond.success
            }
    }
    
    func getMovieRating(of id: Int) -> Observable<Double> {
        return getTotalRatedList()
            .map { totalList in
                totalList.filter({ $0.id == id }).first?.rating ?? 0
            }
    }
    
    private func getTotalRatedList() -> Observable<[MovieListItemDTO]> {
        return getTotalRatedListPages()
            .flatMap { totalPages in
                Observable.zip((1...totalPages).map { page in
                    self.getRatedMovieList(page: page) }
                )
            }
            .map { arrays in
                arrays.flatMap { $0 }
            }
    }
    
    private func getTotalRatedListPages() -> Observable<Int> {
        let rateListRequest = RateListRequest(
            urlPath: "account/" + KeychainManager.shared.getAccountID().description + "/rated/movies?",
            queryParameters: ["api_key": ApiKey.tmdb.description,
                              "session_id": KeychainManager.shared.getSessionID()]
        )
        return urlSessionManager.performDataTask(with: rateListRequest)
            .map { movieList in
                return movieList.totalPages
            }
    }
    
    private func getRatedMovieList(page: Int) -> Observable<[MovieListItemDTO]> {
        let rateListRequest = RateListRequest(
            urlPath: "account/" + KeychainManager.shared.getAccountID().description + "/rated/movies?",
            queryParameters: ["api_key": ApiKey.tmdb.description,
                              "session_id": KeychainManager.shared.getSessionID(),
                              "page": "\(page)"]
        )
        return urlSessionManager.performDataTask(with: rateListRequest)
            .map { $0.results }
    }

}
