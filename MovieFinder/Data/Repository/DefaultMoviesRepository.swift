//
//  Repository.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/26.
//

import Foundation
import RxSwift

protocol MoviesRepository {
    func getMovieListItem(from url: URL?) -> Observable<[MovieListItem]>
}

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

}
