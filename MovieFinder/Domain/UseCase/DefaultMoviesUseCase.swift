//
//  DefaultMoviesUseCase.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/26.
//

import Foundation
import RxSwift

protocol MoviesUseCase {
    func getMovieLists() -> Observable<[MovieList]>
    func getSearchResults(with keyword: String, page: Int) -> Observable<MovieList>
    func getMovieDetail(with id: Int) -> Observable<MovieDetailBasicInfo>
    func getMovieDetailReviews(with id: Int) -> Observable<[MovieDetailReview]>
}

final class DefaultMoviesUseCase: MoviesUseCase {
    private let moviesRepository: MoviesRepository
    
    init(moviesRepository: MoviesRepository) {
        self.moviesRepository = moviesRepository
    }
    
    func getMovieLists() -> Observable<[MovieList]> {
        let lists = HomeMovieLists.allCases
        let genresList = moviesRepository.getGenresList()
        let movieLists = lists.map { section -> Observable<MovieList> in
            let movieList = moviesRepository.getMovieList(with: section.posterPath)
            return makeMovieLists(genresList: genresList, movieList: movieList)
                .map { list in
                    return MovieList(
                        page: list.page,
                        items: list.items,
                        totalPages: list.totalPages,
                        section: section
                    )
                }
        }
        return Observable.zip(movieLists) { $0 }
    }
    
    func getSearchResults(with keyword: String, page: Int = 1) -> Observable<MovieList> {
        let genresList = moviesRepository.getGenresList()
        let movieList = moviesRepository.getSearchResultList(with: keyword, page: page)
        return makeMovieLists(genresList: genresList, movieList: movieList)
    }
    
    private func makeMovieLists(genresList: Observable<GenresDTO>, movieList: Observable<MovieListDTO>) -> Observable<MovieList> {
        return Observable.zip(genresList, movieList) { genresList, movieList in
            let items = movieList.results?.compactMap { movieListItemDTO -> MovieListItem in
                var movieGenres: [Genre] = []
                movieListItemDTO.genreIDS?.forEach { genreID in
                    genresList.genres.forEach { genre in
                        if genreID == genre.id {
                            movieGenres.append(genre)
                        }
                    }
                }
                return movieListItemDTO.convertToEntity(with: movieGenres)
            }
            return movieList.convertToEntity(with: items ?? [])
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
    
    func getMovieDetailReviews(with id: Int) -> Observable<[MovieDetailReview]> {
        return moviesRepository.getMovieDetailReviews(with: id).map { reviews in
            reviews.results.map { reviewDTO in
                reviewDTO.convertToEntity()
            }
        }
    }
    
}


