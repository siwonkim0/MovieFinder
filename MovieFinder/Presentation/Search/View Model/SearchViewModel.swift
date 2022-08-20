//
//  SearchViewModel.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/19.
//

import Foundation
import RxSwift

final class SearchViewModel {
    struct Input {
        let viewWillAppear: Observable<Void>
        let tapRatingButton: Observable<Double>
    }
    
    struct Output {
        let basicInfoObservable: Observable<MovieDetailBasicInfo>
//        let reviewsObservable: Observable<[MovieDetailReview]>
        let ratingObservable: Observable<Double>
    }
    
    let apiManager = APIManager()
    
//    func transform(_ input: Input) -> Output {
//        //todo
//    }
    
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
