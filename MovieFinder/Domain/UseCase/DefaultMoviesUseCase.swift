//
//  DefaultUseCase.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/26.
//

import Foundation
import RxSwift

protocol MoviesUseCase {
    func getMovieLists() -> Observable<[[MovieListItem]]>
    func getSearchResults(with keyword: String, page: Int) -> Observable<[MovieListItem]>
    func getMovieDetail(with id: Int) -> Observable<MovieDetailBasicInfo>
    func getMovieDetailReviews(from id: Int) -> Observable<[MovieDetailReview]>
}

final class DefaultMoviesUseCase: MoviesUseCase {
    let moviesRepository: MoviesRepository
    
    init(moviesRepository: MoviesRepository) {
        self.moviesRepository = moviesRepository
    }
    
    func getMovieLists() -> Observable<[[MovieListItem]]> {
        let lists: [MovieLists: String] = [
            .nowPlaying: "movie/now_playing?",
            .popular: "movie/popular?",
            .topRated: "movie/top_rated?",
            .upComing: "movie/upcoming?"
        ]
        
        let genresList = moviesRepository.getGenresList()
        let movieLists = lists.map { (key, value) -> Observable<[MovieListItem]> in
            let movieList = moviesRepository.getMovieList(with: value)
            return makeMovieLists(genresList: genresList, movieList: movieList)
                .map { itemList in
                    itemList.map { item in
                        return MovieListItem(
                            id: item.id,
                            title: item.title,
                            overview: item.overview,
                            releaseDate: item.releaseDate,
                            posterPath: item.posterPath,
                            originalLanguage: item.originalLanguage,
                            genres: item.genres,
                            section: key
                        )
                    }
                }
        }
        return Observable.zip(movieLists) { $0 }
    }
    
    func getSearchResults(with keyword: String, page: Int = 1) -> Observable<[MovieListItem]> {
        let genresList = moviesRepository.getGenresList()
        let movieList = moviesRepository.getSearchResultList(with: keyword, page: page)
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
    
}


