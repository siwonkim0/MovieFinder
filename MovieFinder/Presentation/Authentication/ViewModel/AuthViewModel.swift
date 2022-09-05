//
//  AuthViewModel.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/18.
//

import UIKit
import RxSwift
import RxCocoa

final class AuthViewModel: ViewModelType {
    struct Input {
        let didTapOpenUrlWithToken: Observable<Void>
        let sceneDidBecomeActive: Observable<Void>
    }
    
    struct Output {
        let tokenUrl: Observable<URL>
        let didSaveSessionId: Observable<Data>
    }
    
    private let useCase: MoviesAuthUseCase
    
    init(useCase: MoviesAuthUseCase) {
        self.useCase = useCase
    }
    
    func transform(_ input: Input) -> Output {
        let url = input.didTapOpenUrlWithToken
            .withUnretained(self)
            .flatMap { (self, _) in
                self.useCase.getUrlWithToken()
            }
        let sceneDidBecomeActive = input.sceneDidBecomeActive
            .withUnretained(self)
            .flatMap { (self, _) in
                self.useCase.createSessionIdWithToken()
            }
            .withUnretained(self)
            .flatMap { (self, _) in
                self.useCase.saveAccountId()
            }
        
        return Output(
            tokenUrl: url,
            didSaveSessionId: sceneDidBecomeActive
        )
    }

}
