//
//  AuthViewReactorTests.swift
//  MovieFinderUnitTests
//
//  Created by Siwon Kim on 2022/10/14.
//

import XCTest
@testable import MovieFinder

import RxSwift

final class AuthViewReactorTests: XCTestCase {
    private var reactor: AuthReactor!
    private var spyUseCase: SpyAuthUseCase!
    
    override func setUp() {
        spyUseCase = SpyAuthUseCase()
        reactor = AuthReactor(useCase: spyUseCase)
    }
    
    func test_didTapOpenURLButton() {
        reactor.action.onNext(.openURL)
        XCTAssertEqual(reactor.currentState.url, URL(string: "url"))
        spyUseCase.verifyGetUrlWithToken(callCount: 1)
    }
    
    func test_didFinishAuthenticate() {
        reactor.action.onNext(.authenticate)
        spyUseCase.verifyCreateSessionIdWithToken(callCount: 1)
        spyUseCase.verifySaveAccountId(callCount: 1)
    }
}
