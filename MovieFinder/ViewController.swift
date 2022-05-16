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
        search(with: "Avengers")
//        getDetails(with: 271110)
//        getReviews(with: 1771)
    }
    
    func search(with keywords: String) {
        let url = URLManager.keyword(language: Language.english.value, keywords: keywords).url
        apiManager.getMovieData(with: url, to: MovieList.self) { result in
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
    
    func getDetails(with id: Int) {
        let url = URLManager.details(id: id, language: Language.english.value).url
        apiManager.getMovieData(with: url, to: MovieDetail.self) { result in
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
    
    func getReviews(with id: Int) {
        let url = URLManager.reviews(id: id).url
        apiManager.getMovieData(with: url, to: ReviewList.self) { result in
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
    }
    
    func getLatest() {
        let url = URLManager.latest.url
        apiManager.getMovieData(with: url, to: MovieDetail.self) { result in
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
    
    func getNowPlaying() {
        let url = URLManager.nowPlaying.url
        apiManager.getMovieData(with: url, to: NowPlayingMovieList.self) { result in
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
    
    func getPopular() {
        let url = URLManager.popular.url
        apiManager.getMovieData(with: url, to: MovieList.self) { result in
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
    
    func getTopRated() {
        let url = URLManager.topRated.url
        apiManager.getMovieData(with: url, to: MovieList.self) { result in
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
    
    func getUpcoming() {
        let url = URLManager.upComing.url
        apiManager.getMovieData(with: url, to: MovieList.self) { result in
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
}
