//
//  DefaultUseCase.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/26.
//

import Foundation

protocol MoviesUseCase {
    func getNowPlaying(completion: @escaping (Result<[ListItem], Error>) -> Void)
}

class DefaultMoviesUseCase: MoviesUseCase {
    let moviesRepository: MoviesRepository
    
    init(moviesRepository: MoviesRepository) {
        self.moviesRepository = moviesRepository
    }
    
    //entity -> Model 변경
    func getNowPlaying(completion: @escaping (Result<[ListItem], Error>) -> Void) {
        moviesRepository.getNowPlaying { result in
            switch result {
            case .success(let listItems):
                var items = [ListItem]()
                listItems.forEach { item in
                    items.append(item.convertToModel())
                }
                completion(.success(items))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
