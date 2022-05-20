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
    private init() { }
    
    var token: String = ""
    
    private func performDataTask<T: Decodable>(with request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) {
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                completion(.failure(URLSessionError.invaildData))
                return
            }
//            print(String(data: data, encoding: .utf8))
            guard let decodedData = JSONParser.decodeData(of: data, type: T.self) else {
                completion(.failure(JSONError.dataDecodeFailed))
                return
            }
            completion(.success(decodedData))
            
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode >= 300 {
                completion(.failure(URLSessionError.responseFailed(code: httpResponse.statusCode)))
                return
            }
            
            if let error = error {
                completion(.failure(URLSessionError.requestFailed(description: error.localizedDescription)))
                return
            }
        }.resume()
    }
    
    private func performDataTaskWithoutDecoding(with request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) {
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                completion(.failure(URLSessionError.invaildData))
                return
            }
            
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
    
    private func performDataTaskImage(with request: URLRequest, completion: @escaping (UIImage) -> Void) {
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                return
            }
            guard let image = UIImage(data: data) else {
                return
            }
            completion(image)
            
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode >= 300 {
                return
            }
            
            if let error = error {
                return
            }
        }.resume()
    }
}

extension APIManager {
    func getData<T: Decodable>(with url: URL?, format type: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = url else {
            return
        }
        let request = URLRequest(url: url, method: .get)
        performDataTask(with: request, completion: completion)
    }
    
    func getPosterImage(with url: URL?, completion: @escaping (UIImage) -> Void) {
        guard let url = url else {
            return
        }
        let request = URLRequest(url: url, method: .get)
        performDataTaskImage(with: request, completion: completion)
    }
    
    func getToken(completion: @escaping (Result<String, Error>) -> Void) {
        let url = URLManager.token.url
        getData(with: url, format: Token.self) { result in
            switch result {
            case .success(let movieToken):
                self.token = movieToken.requestToken
                completion(.success(self.token))
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
    
    func createSessionID(completion: @escaping (Result<Session, Error>) -> Void) {
        let requestToken = RequestToken(requestToken: self.token)
        let jsonData = JSONParser.encodeToData(with: requestToken)
        
        guard let sessionUrl = URLManager.session.url else {
            return
        }
        var request = URLRequest(url: sessionUrl, method: .post)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        performDataTask(with: request, completion: completion)
    }
    
    func rateMovie(value: Double, sessionID: String, movieID: Int, completion: @escaping (Result<Data, Error>) -> Void) {
        let jsonData = JSONParser.encodeToData(with: Rate(value: value))
        guard let url = URLManager.rateMovie(sessionID: sessionID, movieID: movieID).url else {
            return
        }
        var request = URLRequest(url: url, method: .post)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        performDataTaskWithoutDecoding(with: request, completion: completion)
    }
}
