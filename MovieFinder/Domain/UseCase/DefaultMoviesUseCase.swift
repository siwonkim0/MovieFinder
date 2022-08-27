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
    func getMovieDetail(with id: Int) -> Observable<MovieDetailBasicInfo>
    func getMovieDetailReviews(from id: Int) -> Observable<[MovieDetailReview]>
    func updateMovieRating(of id: Int, to rating: Double) -> Observable<Bool>
    func getMovieRating(of id: Int) -> Observable<Double>
    func getSearchResults(with keyword: String) -> Observable<[MovieListItem]>
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
    
    func getMovieDetail(with id: Int) -> Observable<MovieDetailBasicInfo> {
        let omdbMovieDetail = moviesRepository.getOmdbMovieDetail(with: id)
        let tmdbMovieDetail = moviesRepository.getTmdbMovieDetail(with: id)
        return Observable.zip(omdbMovieDetail, tmdbMovieDetail)
            .map { omdb, tmdb in
                return omdb.convertToEntity(with: tmdb)
            }
    }
    
    func getMovieDetailReviews(from id: Int) -> Observable<[MovieDetailReview]> {
        return moviesRepository.getMovieDetailReviews(with: id).map { reviews in
            reviews.results.map { reviewDTO in
                if reviewDTO.content.count <= 300 {
                    return MovieDetailReview(
                        username: reviewDTO.author,
                        rating: reviewDTO.authorDetails.rating ?? 0,
                        content: reviewDTO.content,
                        contentOriginal: reviewDTO.content,
                        contentPreview: reviewDTO.content,
                        createdAt: reviewDTO.createdAt
                    )
                } else {
                    let index = reviewDTO.content.index(reviewDTO.content.startIndex, offsetBy: 300)
                    let previewContent = String(reviewDTO.content[...index])
                    return MovieDetailReview(
                        username: reviewDTO.author,
                        rating: reviewDTO.authorDetails.rating ?? 0,
                        content: reviewDTO.content,
                        contentOriginal: reviewDTO.content,
                        contentPreview: previewContent,
                        createdAt: reviewDTO.createdAt
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
    
    func getSearchResults(with keyword: String) -> Observable<[MovieListItem]> {
        let genresList = moviesRepository.getGenresList()
        let movieList = moviesRepository.getSearchResultList(with: keyword)
        return makeMovieLists(genresList: genresList, movieList: movieList)
    }
    
    private func makeMovieLists(genresList: Observable<GenresDTO>, movieList: Observable<MovieListDTO>) -> Observable<[MovieListItem]> {
        return Observable.zip(genresList, movieList) { genresList, movieList in
            return movieList.results.map { movieListItemDTO -> MovieListItem in
                var movieGenres: [Genre] = []
                movieListItemDTO.genreIDS.forEach { genreID in
                    genresList.genres.forEach { genre in
                        if genreID == genre.id {
                            movieGenres.append(genre)
                        }
                    }
                }
                return movieListItemDTO.convertToEntity(with: movieGenres)
            }
        }
    }
}


