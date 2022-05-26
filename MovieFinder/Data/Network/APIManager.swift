//
//  APIManager.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/16.
//

import Foundation

class APIManager {
    static let shared = APIManager()
    var urlSession: URLSessionProtocol
    
    init(urlSession: URLSessionProtocol = URLSession.shared) {
        self.urlSession = urlSession
    }
    // MARK: - Networking
    private func performDataTask(with request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) {
        urlSession.dataTask(with: request) { data, response, error in
            guard let data = data else {
                completion(.failure(URLSessionError.invaildData))
                return
            }
//            print(String(data: data, encoding: .utf8))
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode >= 300 {
                completion(.failure(URLSessionError.responseFailed(code: httpResponse.statusCode)))
                return
            }
            
            if let error = error {
                completion(.failure(URLSessionError.requestFailed(description: error.localizedDescription)))
                return
            }
            completion(.success(data))
        }.resume()
    }
    
    private func decodeDataAfterDataTask<T: Decodable>(with request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) {
        performDataTask(with: request) { result in
            switch result {
            case .success(let data):
                guard let decodedData = JSONParser.decodeData(of: data, type: T.self) else {
                    completion(.failure(JSONError.dataDecodeFailed))
                    return
                }
                completion(.success(decodedData))
            case .failure(let error):
                print("\(error)")
            }
        }
    }
}

extension APIManager {
    // MARK: - CRUD
    func getData<T: Decodable>(from url: URL?, format type: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = url else {
            return
        }
        let request = URLRequest(url: url, method: .get)
        decodeDataAfterDataTask(with: request, completion: completion)
    }
    
    func postData(_ data: Data?, to url: URL?, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = url, let data = data else {
            return
        }
        var request = URLRequest(url: url, method: .post)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        performDataTask(with: request, completion: completion)
    }
    
    func postDataWithDecodingResult<T: Decodable>(_ data: Data?, to url: URL?, format type: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = url, let data = data else {
            return
        }
        var request = URLRequest(url: url, method: .post)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        decodeDataAfterDataTask(with: request, completion: completion)
    }
    
    func deleteData(at url: URL?, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = url else {
            return
        }
        var request = URLRequest(url: url, method: .delete)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        performDataTask(with: request, completion: completion)
    }
}
