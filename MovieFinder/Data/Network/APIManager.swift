//
//  APIManager.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/16.
//

import Foundation
import RxSwift

class APIManager {
    var urlSession: URLSessionProtocol

    init(urlSession: URLSessionProtocol = URLSession.shared) {
        self.urlSession = urlSession
    }
    // MARK: - Networking
    private func performDataTask(with request: URLRequest) -> Observable<Data> {
        return Observable<Data>.create { observer in
            let task = self.urlSession.dataTask(with: request) { data, response, error in
                guard let data = data else {
                    observer.onError(URLSessionError.invaildData)
                    return
                }
                if let httpResponse = response as? HTTPURLResponse,
                   httpResponse.statusCode >= 300 {
                    observer.onError(URLSessionError.responseFailed(code: httpResponse.statusCode))
                    return
                }
                
                if let error = error {
                    observer.onError(URLSessionError.requestFailed(description: error.localizedDescription))
                    return
                }
                observer.onNext(data)
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
    private func decodeDataAfterDataTask<T: Decodable>(with request: URLRequest) -> Observable<T> {
        return self.performDataTask(with: request)
            .map { data in
                guard let decodedData = JSONParser.decodeData(of: data, type: T.self) else {
                    throw JSONError.dataDecodeFailed
                }
                return decodedData
            }
    }
        
}

extension APIManager {
    // MARK: - CRUD
    // TODO: - Remove get from method name: async functions should avoid "get"
    func getData<T: Decodable>(from url: URL?, format type: T.Type) -> Observable<T> {
        guard let url = url else {
            return .empty() //하....
        }
        let request = URLRequest(url: url, method: .get)
        return decodeDataAfterDataTask(with: request)
    }
    
    func postData(_ data: Data?, to url: URL?) -> Observable<Data> {
        guard let url = url, let data = data else {
            return .empty()
        }
        var request = URLRequest(url: url, method: .post)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        return performDataTask(with: request)
    }
    
    func postDataWithDecodingResult<T: Decodable>(_ data: Data?, to url: URL?, format type: T.Type) -> Observable<T> {
        guard let url = url, let data = data else {
            return .empty()
        }
        var request = URLRequest(url: url, method: .post)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        return decodeDataAfterDataTask(with: request)
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
