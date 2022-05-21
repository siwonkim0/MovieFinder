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

    private func performDataTask<T: Decodable>(with request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) {
        urlSession.dataTask(with: request) { data, response, error in
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
        urlSession.dataTask(with: request) { data, response, error in
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
    
    private func performDataTaskImage(with request: URLRequest, completion: @escaping (Result<UIImage, Error>) -> Void) {
        urlSession.dataTask(with: request) { data, response, error in
            guard let data = data else {
                return
            }
            guard let image = UIImage(data: data) else {
                return
            }
            completion(.success(image))
            
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
}

extension APIManager {
    func getData<T: Decodable>(from url: URL?, format type: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = url else {
            return
        }
        let request = URLRequest(url: url, method: .get)
        performDataTask(with: request, completion: completion)
    }
    
    func getImage(with url: URL?, completion: @escaping (Result<UIImage, Error>) -> Void) {
        guard let url = url else {
            return
        }
        let request = URLRequest(url: url, method: .get)
        performDataTaskImage(with: request, completion: completion)
    }
    
    func postData<T: Decodable>(_ data: Data?, to url: URL?, format type: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = url, let data = data else {
            return
        }
        var request = URLRequest(url: url, method: .post)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
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
    
    func deleteRating(sessionID: String, movieID: Int, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URLManager.deleteRating(sessionID: sessionID, movieID: movieID).url else {
            return
        }
        var request = URLRequest(url: url, method: .delete)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        performDataTaskWithoutDecoding(with: request, completion: completion)
    }
}
