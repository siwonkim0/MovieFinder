//
//  ViewController.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/13.
//

import UIKit

class ViewController: UIViewController {
    let apiManager = APIManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        apiManager.searchByKeywords(keywords: "Avengers") { result in
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

        apiManager.getDetails(id: 271110) { result in
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
        
        apiManager.getReviews(id: 1771) { result in
            switch result {
            case .success(let reviews):
                reviews.results.forEach {
                    print($0.content)
                }
                print(reviews.results[0].content)
            case .failure(let error):
                if let error = error as? URLSessionError {
                    print(error.errorDescription)
                }
                if let error = error as? JSONError {
                    print("data decode failure: \(error.localizedDescription)")
                }
            }
        }
        
        apiManager.getLatest { result in
            switch result {
            case .success(let movie):
                print(movie.originalTitle)
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

}

