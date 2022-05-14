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
        searchKeywords { result in
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
    }
    
    func searchKeywords(completion: @escaping (Result<MovieList, Error>) -> Void) {
        guard let url = URLManager.searchKeywords(language: Language.english.value, keywords: "Avengers").url else {
            return
        }
        let request = URLRequest(url: url, method: .get)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                completion(.failure(URLSessionError.invaildData))
                return
            }
            guard let decodedData = JSONParser.decodeData(of: data, type: MovieList.self) else {
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

