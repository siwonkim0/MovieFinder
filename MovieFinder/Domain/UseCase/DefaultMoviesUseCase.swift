//
//  DefaultUseCase.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/26.
//

import Foundation
import RxSwift

protocol MoviesUseCase {
    func getMovieListItem(from listUrl: MovieListURL) -> Observable<[MovieListItem]>
    func getMovieDetailItem(from id: Int) -> Observable<MovieDetailBasicInfo>
    func getMovieDetailReviews(from id: Int) -> Observable<[MovieDetailReview]>
    func updateMovieRating(of id: Int, to rating: Double) -> Observable<Bool>
    func getMovieRating(of id: Int) -> Observable<Double>
}

final class DefaultMoviesUseCase: MoviesUseCase {
    let moviesRepository: MoviesRepository
    
    init(moviesRepository: MoviesRepository) {
        self.moviesRepository = moviesRepository
    }
    
    func getMovieListItem(from listUrl: MovieListURL) -> Observable<[MovieListItem]> {
        let url = listUrl.url
        return moviesRepository.getMovieListItem(from: url)
    }
    
    func getMovieDetailItem(from id: Int) -> Observable<MovieDetailBasicInfo> {
        return moviesRepository.getMovieDetail(with: id)
    }
    
    func getMovieDetailReviews(from id: Int) -> Observable<[MovieDetailReview]> {
        return moviesRepository.getMovieDetailReviews(with: id)
            .map { movies in
                movies.map { movie in
                    if movie.content.count <= 300 {
                        return MovieDetailReview(id: movie.id,
                                                 username: movie.username,
                                                 rating: movie.rating,
                                                 content: movie.content,
                                                 contentOriginal: movie.content,
                                                 contentPreview: movie.content,
                                                 createdAt: movie.createdAt,
                                                 showAllContent: movie.showAllContent
                        )
                    } else {
                        let index = movie.content.index(movie.content.startIndex, offsetBy: 300)
                        let previewContent = String(movie.content[...index]) + "..."
                        return MovieDetailReview(id: movie.id,
                                                 username: movie.username,
                                                 rating: movie.rating,
                                                 content: movie.content,
                                                 contentOriginal: movie.content,
                                                 contentPreview: previewContent,
                                                 createdAt: movie.createdAt,
                                                 showAllContent: movie.showAllContent
                        )
                    }
                }
            }
    }
    
    func updateMovieRating(of id: Int, to rating: Double) -> Observable<Bool> {
        return moviesRepository.updateMovieRating(of: id, to: rating)
    }
    
    func getMovieRating(of id: Int) -> Observable<Double> {
        return moviesRepository.getMovieRating(of: id)
    }
}
