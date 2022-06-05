//
//  Repository.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/26.
//

import Foundation

protocol MoviesRepository {
    func getMovieListItem(from url: URL?, completion: @escaping (Result<[MovieListItem], Error>) -> Void)
}

class DefaultMoviesRepository: MoviesRepository {
    let apiManager: APIManager
    
    init(apiManager: APIManager) {
        self.apiManager = apiManager
    }
    
    private func getGenres(completion: @escaping (Result<GenresDTO, Error>) -> Void) {
        let url = MovieURL.genres.url
        apiManager.getData(from: url, format: GenresDTO.self) { result in
            switch result {
            case .success(let genreList):
                completion(.success(genreList))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

extension DefaultMoviesRepository {
    func getMovieListItem(from url: URL?, completion: @escaping (Result<[MovieListItem], Error>) -> Void) {
        self.getGenres { result in
            if case .success(let genresList) = result {
                self.apiManager.getData(from: url, format: MovieListDTO.self) { moviesResult in
                    if case .success(let moviesResult) = moviesResult {
                        let listItems = moviesResult.results.map { movieListItemDTO -> MovieListItem in
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
                        completion(.success(listItems))
                    }
                }
            }
        }
    }
}
