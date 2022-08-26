//
//  DefaultUseCase.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/26.
//

import Foundation
import RxSwift

protocol MoviesUseCase {
    func getMovieLists() -> Observable<[Section]>
    func getMovieDetailItem(from id: Int) -> Observable<MovieDetailBasicInfo>
    func getMovieDetailReviews(from id: Int) -> Observable<[MovieDetailReview]>
    func updateMovieRating(of id: Int, to rating: Double) -> Observable<Bool>
    func getMovieRating(of id: Int) -> Observable<Double>
    func getSearchResults(with keyword: String) -> Observable<[SearchCellViewModel]>
}

final class DefaultMoviesUseCase: MoviesUseCase {
    let moviesRepository: MoviesRepository
    let accountRepository: AccountRepository
    
    init(moviesRepository: MoviesRepository, accountRepository: AccountRepository) {
        self.moviesRepository = moviesRepository
        self.accountRepository = accountRepository
    }
    
    func getMovieLists() -> Observable<[Section]> {
        return moviesRepository.getAllMovieLists()
            .map { items in
                items.map { lists in
                    lists.map { item in
                        MovieListCellViewModel(movie: item, section: item.section!)
                    }
                }
            }
            .map { items in
                return items.map { items in
                    let title = items.map({$0.section.title}).first ?? ""
                    return Section(title: title, movies: items)
                }
            }
    }
    
    func getMovieDetailItem(from id: Int) -> Observable<MovieDetailBasicInfo> {
        return moviesRepository.getMovieDetail(with: id)
    }
    
    func getMovieDetailReviews(from id: Int) -> Observable<[MovieDetailReview]> {
        return moviesRepository.getMovieDetailReviews(with: id)
            .map { movies in
                movies.map { movie in
                    if movie.content.count <= 300 {
                        return MovieDetailReview(
                            id: movie.id,
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
                        let previewContent = String(movie.content[...index])
                        return MovieDetailReview(
                            id: movie.id,
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
        return accountRepository.updateMovieRating(of: id, to: rating)
    }
    
    func getMovieRating(of id: Int) -> Observable<Double> {
        return accountRepository.getMovieRating(of: id)
    }
    
    func getSearchResults(with keyword: String) -> Observable<[SearchCellViewModel]> {
        return moviesRepository.getSearchMovieList(with: keyword)
            .map { results in
                results
                    .filter { $0.posterPath != "" }
                    .map { SearchCellViewModel(movie: $0) }
            }
    }
}
