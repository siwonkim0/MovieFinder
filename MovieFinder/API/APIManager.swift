//
//  APIManager.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/16.
//

import Foundation

struct APIManager {
    func performDataTask<T: Decodable>(with request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) {
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
}

extension APIManager {
    func searchByKeywords(keywords: String, completion: @escaping (Result<MovieList, Error>) -> Void) {
        guard let url = URLManager.keyword(language: Language.english.value, keywords: keywords).url else {
            return
        }
        let request = URLRequest(url: url, method: .get)
        performDataTask(with: request, completion: completion)
    }

    func getDetails(id: Int, completion: @escaping (Result<MovieDetail, Error>) -> Void) {
        guard let url = URLManager.details(id: id, language: Language.english.value).url else {
            return
        }
        let request = URLRequest(url: url, method: .get)
        performDataTask(with: request, completion: completion)
    }
    
    func getReviews(id: Int, completion: @escaping (Result<ReviewList, Error>) -> Void) {
        guard let url = URLManager.reviews(id: id).url else {
            return
        }
        let request = URLRequest(url: url, method: .get)
        performDataTask(with: request, completion: completion)
    }
    
    func getLatest(completion: @escaping (Result<MovieDetail, Error>) -> Void) {
        guard let url = URLManager.latest.url else {
            return
        }
        let request = URLRequest(url: url, method: .get)
        performDataTask(with: request, completion: completion)
    }
}
