//
//  Repository.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/26.
//

import Foundation

protocol MoviesRepository {
    func getMovieListItem(from url: URL?) async throws -> [MovieListItem]
}

class DefaultMoviesRepository: MoviesRepository {
    let apiManager: APIManager
    
    init(apiManager: APIManager) {
        self.apiManager = apiManager
    }
    func getMovieListItem(from url: URL?) async throws -> [MovieListItem] {
        return try await Task { () -> [MovieListItem] in
            async let genresListTask = try await apiManager.getData(from: MovieURL.genres.url, format: GenresDTO.self)
            async let moviesResultTask = try await apiManager.getData(from: url, format: MovieListDTO.self)
            let genresList = try await genresListTask
            let moviesResult = try await moviesResultTask
            
            return moviesResult.results.map { movieListItemDTO -> MovieListItem in
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
        }.value
    }

}
