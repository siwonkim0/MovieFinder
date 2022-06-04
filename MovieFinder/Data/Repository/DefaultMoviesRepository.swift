//
//  Repository.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/26.
//

import Foundation

protocol MoviesRepository {
    func getNowPlayingWithGenres(completion: @escaping (Result<[ListItem], Error>) -> Void)
}

class DefaultMoviesRepository: MoviesRepository {
    let apiManager: APIManager
    
    init(apiManager: APIManager) {
        self.apiManager = apiManager
    }
    
    private func getNowPlaying(completion: @escaping (Result<[MovieListItem], Error>) -> Void) {
        let url = MovieURL.nowPlaying.url
        apiManager.getData(from: url, format: MovieList.self) { result in
            switch result {
            case .success(let movieList):
                completion(.success(movieList.results))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func getGenres(completion: @escaping (Result<Genres, Error>) -> Void) {
        let url = MovieURL.genres.url
        apiManager.getData(from: url, format: Genres.self) { result in
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
    func getNowPlayingWithGenres(completion: @escaping (Result<[ListItem], Error>) -> Void) {
        self.getGenres { genresResult in
            if case .success(let genresResult) = genresResult {
                self.getNowPlaying { moviesResult in
                    if case .success(let moviesResult) = moviesResult {
                        var listItems: [ListItem] = []
                        moviesResult.forEach { item in
                            
                            var movieGenres: [Genre] = []
                            item.genreIDS.forEach { genreID in
                                genresResult.genres.forEach { genre in
                                    if genreID == genre.id {
                                        movieGenres.append(genre)
                                    }
                                }
                            }
                            let listItem = item.convertToModel(with: movieGenres)
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
