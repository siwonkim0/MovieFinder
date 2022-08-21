//
//  APIManager.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/16.
//

import Foundation
import RxSwift

final class URLSessionManager {
    var urlSession: URLSessionProtocol

    init(urlSession: URLSessionProtocol = URLSession.shared) {
        self.urlSession = urlSession
    }
    // MARK: - Networking
    //to delete
    private func performDataTask<T: Decodable>(with request: URLRequest) -> Observable<T> {
        return Observable<T>.create { observer in
            let task = self.urlSession.dataTask(with: request) { data, response, error in
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
                
                guard let decodedData = JSONParser.decodeData(of: data, type: T.self) else {
                    return
                }

                observer.onNext(decodedData)
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
    //new
    func performDataTask2<T: NetworkRequest>(with requestType: T) -> Observable<T.ResponseType> {
        return Observable.create { observer in
            guard let request = requestType.urlRequest else {
                observer.onError(URLSessionError.invalidRequest)
                return Disposables.create()
            }
            let task = self.urlSession.dataTask(with: request) { data, response, error in
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
            task.resume()
            return Disposables.create {
                task.cancel()
            }
        }
    }
        
}

//to delete
extension URLSessionManager {
    // MARK: - CRUD
    func getData<T: Decodable>(from url: URL?, format type: T.Type) -> Observable<T> {
        guard let url = url else {
            return .empty()
        }
        let request = URLRequest(url: url, method: .get)
        return performDataTask(with: request)
    }

    func postData<T: Decodable>(_ data: Data?, to url: URL?, format type: T.Type? = nil) -> Observable<T> {
        guard let url = url, let data = data else {
            return .empty()
        }
        var request = URLRequest(url: url, method: .post)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data

        return performDataTask(with: request)
    }

    func deleteData(at url: URL?) -> Observable<Data> {
        guard let url = url else {
            return .empty()
        }
        var request = URLRequest(url: url, method: .delete)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        return performDataTask(with: request)
    }
}
