//
//  Repository.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/26.
//

import Foundation

protocol MoviesRepository {
    func getNowPlayingWithGenres(completion: @escaping (Result<[MovieListItem], Error>) -> Void)
}

class DefaultMoviesRepository: MoviesRepository {
    let apiManager: APIManager
    
    init(apiManager: APIManager) {
        self.apiManager = apiManager
    }
    
    private func getNowPlaying(completion: @escaping (Result<[MovieListItemDTO], Error>) -> Void) {
        let url = MovieURL.nowPlaying.url
        apiManager.getData(from: url, format: MovieListDTO.self) { result in
            switch result {
            case .success(let movieList):
                completion(.success(movieList.results))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func getGenres(completion: @escaping (Result<GenresDTO, Error>) -> Void) {
        let url = MovieURL.genres.url
        apiManager.getData(from: url, format: GenresDTO.self) { result in
            switch result {
            case .success(let genreList):
                completion(.success(genreList))
                print(genreList.genres[0])
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

extension DefaultMoviesRepository {
    func getNowPlayingWithGenres(completion: @escaping (Result<[MovieListItem], Error>) -> Void) {
        self.getGenres { genresResult in
            if case .success(let genresResult) = genresResult {
                self.getNowPlaying { moviesResult in
                    if case .success(let moviesResult) = moviesResult {
                        var listItems: [MovieListItem] = []
                        moviesResult.forEach { item in
                            
                            var movieGenres: [Genre] = []
                            item.genreIDS.forEach { genreID in
                                genresResult.genres.forEach { genre in
                                    if genreID == genre.id {
                                        movieGenres.append(genre)
                                    }
                                }
                            }
                            let listItem = item.convertToEntity(with: movieGenres)
                            listItems.append(listItem)
//                            print(movieGenres)
                        }
                        completion(.success(listItems))
                    }
                }
            }
        }
    }
}
