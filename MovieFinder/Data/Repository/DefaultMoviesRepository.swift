//
//  Repository.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/26.
//

import Foundation
import RxSwift

final class DefaultMoviesRepository: MoviesRepository {
    let apiManager: APIManager
    
    init(apiManager: APIManager) {
        self.apiManager = apiManager
    }
    
    func getMovieListItem(from url: URL?) -> Observable<[MovieListItem]> {
        let genres = apiManager.getData(from: MovieURL.genres.url, format: GenresDTO.self)
        let movies = apiManager.getData(from: url, format: MovieListDTO.self)
        
        return Observable.zip(genres, movies) { genresList, movieList in
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
        let omdbMovieDetail = apiManager.getData(from: MovieURL.details(id: id).url, format: TMDBMovieDetailDTO.self)
            .withUnretained(self)
            .flatMap { (self, detail) in
                return self.apiManager.getData(from: MovieURL.omdbDetails(id: detail.imdbID!).url, format: OMDBMovieDetailDTO.self)
            }
        let tmdbMovieDetail = apiManager.getData(from: MovieURL.details(id: id).url, format: TMDBMovieDetailDTO.self)
        return Observable.zip(omdbMovieDetail, tmdbMovieDetail)
            .map { omdb, tmdb in
                omdb.convertToEntity(with: tmdb)
            }
    }

}
