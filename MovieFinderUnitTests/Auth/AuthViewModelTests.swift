//
//  AuthViewModelTests.swift
//  MovieFinderUnitTests
//
//  Created by Siwon Kim on 2022/09/02.
//

import XCTest
@testable import MovieFinder

import RxSwift

final class AuthViewModelTests: XCTestCase {
    private var disposeBag: DisposeBag!
    private var useCase: MockAuthUseCase!
    private var viewModel: AuthViewModel!
    private var output: AuthViewModel.Output!
    private var tapButtonSubject: BehaviorSubject<Void>!
    private var sceneWillEnterForegroundSubject: BehaviorSubject<Void>!
    
    override func setUp() {
        disposeBag = DisposeBag()
        tapButtonSubject = BehaviorSubject<Void>(value: ())
        sceneWillEnterForegroundSubject = BehaviorSubject<Void>(value: ())
        useCase = MockAuthUseCase()
        viewModel = AuthViewModel(useCase: useCase)
        
        output = viewModel.transform(.init(
            didTapOpenUrlWithToken: tapButtonSubject.asObservable(),
            sceneWillEnterForeground: sceneWillEnterForegroundSubject.asObservable()
        ))
    }
    
    func test_tokenUrl() {
        tapButtonSubject.onNext(())
        output.tokenUrl
            .subscribe(onNext: { url in
                XCTAssertEqual(url, URL(string: "url"))
                self.useCase.verifyGetUrlWithTokenCallCount()
            })
            .disposed(by: disposeBag)
    }
    
    func test_didSaveSessionId() {
        output.didSaveSessionId
            .subscribe(onNext: { data in
                XCTAssertEqual(String(decoding: data, as: UTF8.self), "data")
                self.useCase.verifyCreateSessionIdWithTokenCallCount()
                self.useCase.verifySaveAccountIdCallCount()
            })
            .disposed(by: disposeBag)
    }
}
