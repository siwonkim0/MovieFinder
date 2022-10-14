//
//  AuthViewReactorTests.swift
//  MovieFinderUnitTests
//
//  Created by Siwon Kim on 2022/10/14.
//

import XCTest
@testable import MovieFinder

import RxSwift
import ReactorKit

final class AuthViewReactorTests: XCTestCase {
    var disposeBag: DisposeBag!
    var reactor: AuthReactor!
    
    func test_didTapOpenURLButton() {
        let useCase = SpyAuthUseCase()
        reactor = AuthReactor(useCase: useCase)
        
        reactor.action.onNext(.openURL)
        XCTAssertEqual(reactor.currentState.url, URL(string: "url"))
        useCase.verifyGetUrlWithTokenCallCount()
    }
    
    func test_didFinishAuthenticate() {
        let useCase = SpyAuthUseCase()
        reactor = AuthReactor(useCase: useCase)
        
        reactor.action.onNext(.authenticate)
        useCase.verifyCreateSessionIdWithTokenCallCount()
        useCase.verifySaveAccountIdCallCount()
    }
}
