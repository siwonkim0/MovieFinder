//
//  MovieListViewModel.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/19.
//

import UIKit

final class MovieListViewModel {
    func getNowPlaying(completion: @escaping (Result<UIImage, Error>) -> Void) {
        let url = MovieURL.nowPlaying.url
        APIManager.shared.getData(from: url, format: NowPlayingMovieList.self) { result in
            switch result {
            case .success(let movieList):
                movieList.results.forEach {
                    print($0.originalTitle)
                }
                guard let posterPath = movieList.results[0].posterPath else {
                    print("no image")
                    return
                }
                self.getImage(with: posterPath, completion: completion)
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
        let url = MovieURL.popular.url
        APIManager.shared.getData(from: url, format: MovieList.self) { result in
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
        let url = MovieURL.topRated.url
        APIManager.shared.getData(from: url, format: MovieList.self) { result in
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
        let url = MovieURL.upComing.url
        APIManager.shared.getData(from: url, format: MovieList.self) { result in
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
    
    func getImage(with posterPath: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        let url = MovieURL.image(posterPath: posterPath).url
        APIManager.shared.getImage(with: url) { result in
            switch result {
            case .success(let image):
                completion(.success(image))
            case .failure(let error):
                print(error)
            }
        }
    }
}
