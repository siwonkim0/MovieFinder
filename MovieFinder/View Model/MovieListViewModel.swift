//
//  MovieListViewModel.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/19.
//

import Foundation

final class MovieListViewModel {
    func getLatest() {
        let url = URLManager.latest.url
        APIManager.shared.getData(from: url, format: MovieDetail.self) { result in
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
        APIManager.shared.getData(from: url, format: NowPlayingMovieList.self) { result in
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
        let url = URLManager.topRated.url
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
        let url = URLManager.upComing.url
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
}
