//
//  SearchViewModel.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/19.
//

import Foundation

final class SearchViewModel {
    let apiManager = APIManager()
    
//    func search(with keywords: String) {
//        let url = MovieURL.keyword(language: Language.english.value, keywords: keywords).url
//        apiManager.getData(from: url, format: MovieListDTO.self) { result in
//            switch result {
//            case .success(let movieList):
//                movieList.results.forEach {
//                    print($0.originalTitle)
//                }
//            case .failure(let error):
//                if let error = error as? URLSessionError {
//                    print(error.errorDescription)
//                }
//                
//                if let error = error as? JSONError {
//                    print("data decode failure: \(error.localizedDescription)")
//                }
//            }
//        }
//    }
}
