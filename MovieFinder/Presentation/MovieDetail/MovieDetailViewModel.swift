//
//  MovieDetailViewModel.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/19.
//

import Foundation

final class MovieDetailViewModel {
    let apiManager = APIManager()
    
    func getDetails(with id: Int, completion: @escaping (Result<TMDBMovieDetailDTO, Error>) -> Void) {
        let url = MovieURL.details(id: id, language: Language.english.value).url
        apiManager.getData(from: url, format: TMDBMovieDetailDTO.self) { result in
            switch result {
            case .success(let movieDetail):
                //뷰 업데이트
                print(movieDetail.originalTitle)
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
        let url = MovieURL.omdbDetails(id: id).url
        apiManager.getData(from: url, format: OMDBMovieDetailDTO.self) { result in
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
        let url = MovieURL.reviews(id: id).url
        apiManager.getData(from: url, format: ReviewListDTO.self) { result in
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
    
    func getVideoId(with id: Int) {
        let url = MovieURL.video(id: id).url
        apiManager.getData(from: url, format: VideoListDTO.self) { result in
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
    
    private func rateMovie(value: Double, sessionID: String, movieID: Int, completion: @escaping (Result<Data, Error>) -> Void) {
        let jsonData = JSONParser.encodeToData(with: RateDTO(value: value))
        let url = MovieURL.rateMovie(sessionID: sessionID, movieID: movieID).url
        apiManager.postData(jsonData, to: url, completion: completion)
    }
    
    func rateMovie(value: Double, movieID: Int) {
        let sessionID = KeychainManager.shared.getSessionID()
        rateMovie(value: value, sessionID: sessionID, movieID: movieID) { result in
            switch result {
            case .success(_):
                print("rate success")
            case .failure(let error):
                print("failed to rate:", error)
            }
        }
    }
    
    func getRatedMovies(sessionID: String, accountID: Int) {
        guard let url = MovieURL.ratedMovies(sessionID: sessionID, accountID: accountID).url else {
            return
        }
        apiManager.getData(from: url, format: MovieListDTO.self) { result in
            switch result {
            case .success(let movieList):
                movieList.results.forEach {
                    print($0.title, $0.rating)
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
    
    private func deleteRating(sessionID: String, movieID: Int, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = MovieURL.deleteRating(sessionID: sessionID, movieID: movieID).url else {
            return
        }
        apiManager.deleteData(at: url, completion: completion)
    }
    
    func deleteRating(sessionID: String, movieID: Int) {
        deleteRating(sessionID: sessionID, movieID: movieID) { result in
            switch result {
            case .success(_):
                print("delete success")
            case .failure(let error):
                print("failed to delete:", error)
            }
        }
    }
}
