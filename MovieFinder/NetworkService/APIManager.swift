//
//  APIManager.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/16.
//

import Foundation
import UIKit

class APIManager {
    static let shared = APIManager()
    let urlSession: URLSessionProtocol
    var token: String = ""
    
    init(urlSession: URLSessionProtocol = URLSession.shared) {
        self.urlSession = urlSession
    }

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
    
    private func convertToUIImageAfterDataTask(with request: URLRequest, completion: @escaping (Result<UIImage, Error>) -> Void) {
        performDataTask(with: request) { result in
            switch result {
            case .success(let data):
                guard let image = UIImage(data: data) else {
                    return
                }
                completion(.success(image))
            case .failure(let error):
                print("\(error)")
            }
        }
    }
}

extension APIManager {
    func getData<T: Decodable>(from url: URL?, format type: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = url else {
            return
        }
        let request = URLRequest(url: url, method: .get)
        decodeDataAfterDataTask(with: request, completion: completion)
    }
    
    func getImage(with url: URL?, completion: @escaping (Result<UIImage, Error>) -> Void) {
        guard let url = url else {
            return
        }
        let request = URLRequest(url: url, method: .get)
        convertToUIImageAfterDataTask(with: request, completion: completion)
    }
    
    func postData<T: Decodable>(_ data: Data?, to url: URL?, format type: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = url, let data = data else {
            return
        }
        var request = URLRequest(url: url, method: .post)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        decodeDataAfterDataTask(with: request, completion: completion)
    }

    func rateMovie(value: Double, sessionID: String, movieID: Int, completion: @escaping (Result<Data, Error>) -> Void) {
        let jsonData = JSONParser.encodeToData(with: Rate(value: value))
        guard let url = URLManager.rateMovie(sessionID: sessionID, movieID: movieID).url else {
            return
        }
        var request = URLRequest(url: url, method: .post)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        performDataTask(with: request, completion: completion)
    }
    
    func deleteRating(sessionID: String, movieID: Int, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URLManager.deleteRating(sessionID: sessionID, movieID: movieID).url else {
            return
        }
        var request = URLRequest(url: url, method: .delete)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        performDataTask(with: request, completion: completion)
    }
}
