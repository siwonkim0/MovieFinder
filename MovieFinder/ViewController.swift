//
//  ViewController.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/13.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        searchByKeywords(keywords: "Avengers") { result in
            switch result {
            case .success(let movieList):
                movieList.results.forEach {
                    print($0.originalTitle)
                }
            case .failure(let error):
                if let error = error as? URLSessionError {
                    print(error.errorDescription)
                }

                if let error = error as? JSONError {
                    print("data decode failure: \(error.localizedDescription)")
                }

            }
        }

        fetchDetails(id: 271110) { result in
            switch result {
            case .success(let movieDetail):
                print(movieDetail.originalTitle)
                print(movieDetail.collection!.name)
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
    
    func searchByKeywords(keywords: String, completion: @escaping (Result<MovieList, Error>) -> Void) {
        guard let url = URLManager.searchKeywords(language: Language.english.value, keywords: keywords).url else {
            return
        }
        let request = URLRequest(url: url, method: .get)
        
        performDataTask(with: request, completion: completion)
    }

    func fetchDetails(id: Int, completion: @escaping (Result<MovieDetail, Error>) -> Void) {
        guard let url = URLManager.fetchDetails(id: id, language: Language.english.value).url else {
            return
        }
        print(url)
        let request = URLRequest(url: url, method: .get)
        
        performDataTask(with: request, completion: completion)
    }
    
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

