//
//  MovieDetailViewModel.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/19.
//

import Foundation

final class MovieDetailViewModel {
    func getDetails(with id: Int, completion: @escaping (Result<MovieDetail, Error>) -> Void) {
        let url = URLManager.details(id: id, language: Language.english.value).url
        APIManager.shared.getData(with: url, format: MovieDetail.self) { result in
            switch result {
            case .success(let movieDetail):
                print(movieDetail.originalTitle)
                print(movieDetail.posterPath)
                completion(.success(movieDetail))
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
    
    func getOMDBDetails(with id: String) {
        let url = URLManager.omdbDetails(id: id).url
        APIManager.shared.getData(with: url, format: OMDBMovieDetail.self) { result in
            switch result {
            case .success(let movieDetail):
                print(movieDetail.director)
                print(movieDetail.actors)
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
        APIManager.shared.getData(with: url, format: ReviewList.self) { result in
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
    

    
    func getImage(with posterPath: String) {
        let url = URLManager.image(posterPath: posterPath).url
        APIManager.shared.getPosterImage(with: url) { image in
//            DispatchQueue.main.async {
//                self.posterImage.image = image
//            }
        }
    }
    
    func getVideoId(with id: Int) {
        let url = URLManager.video(id: id).url
        APIManager.shared.getData(with: url, format: VideoList.self) { result in
            switch result {
            case .success(let videoList):
                videoList.results.forEach { video in
                    print(video.id)
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
    
    func rateMovie(value: Double, movieID: Int) {
        let sessionID = KeychainManager.shared.getSessionID()
        APIManager.shared.rateMovie(value: value, sessionID: sessionID, movieID: movieID) { result in
            switch result {
            case .success(_):
                print("rate success")
            case .failure(let error):
                print("failed to rate:", error)
            }
        }
    }
}
