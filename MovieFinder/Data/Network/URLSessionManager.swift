//
//  URLSessionManager.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/16.
//

import Foundation
import RxSwift

final class URLSessionManager {
    private var urlSession: URLSessionProtocol

    init(urlSession: URLSessionProtocol = URLSession.shared) {
        self.urlSession = urlSession
    }

    // MARK: - Networking
    func performDataTask<T: NetworkRequest>(with requestType: T) -> Observable<T.ResponseType> {
        return Observable.create { [weak self] observer in
            guard let request = requestType.urlRequest else {
                observer.onError(URLSessionError.invalidRequest)
                return Disposables.create()
            }
            let task = self?.urlSession.dataTask(with: request) { data, response, error in
                if let error = error {
                    observer.onError(URLSessionError.requestFailed(description: error.localizedDescription))
                    return
                }
                if let httpResponse = response as? HTTPURLResponse,
                   httpResponse.statusCode >= 300 {
                    observer.onError(URLSessionError.responseFailed(code: httpResponse.statusCode))
                    return
                }
                guard let data = data else {
                    observer.onError(URLSessionError.invaildData)
                    return
                }
                guard let decodedData = JSONParser.decodeData(of: data, type: T.ResponseType.self) else {
                    return
                }
                observer.onNext(decodedData)
            }
            task?.resume()
            return Disposables.create {
                task?.cancel()
            }
        }
    }
        
}
