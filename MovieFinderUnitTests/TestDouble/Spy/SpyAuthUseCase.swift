//
//  SpyAuthUseCase.swift
//  MovieFinderUnitTests
//
//  Created by Siwon Kim on 2022/09/02.
//

import XCTest
@testable import MovieFinder

import RxSwift

final class SpyAuthUseCase: MoviesAuthUseCase {
    private var getUrlWithTokenCallCount: Int = 0
    private var createSessionIdWithTokenCallCount: Int = 0
    private var saveAccountIdCallCount: Int = 0
    
    func getUrlWithToken() -> Observable<URL> {
        getUrlWithTokenCallCount += 1
        let url = URL(string: "url")!
        return Observable.just(url)
    }
    
    func createSessionIdWithToken() -> Observable<Void> {
        createSessionIdWithTokenCallCount += 1
        return Observable.just(())
    }
    
    func saveAccountId() -> Observable<Data> {
        saveAccountIdCallCount += 1
        let data = "data".data(using: .utf8)!
        return Observable.just(data)
    }
    
    func verifyGetUrlWithToken(callCount: Int) {
        XCTAssertEqual(getUrlWithTokenCallCount, callCount)
    }
    
    func verifyCreateSessionIdWithToken(callCount: Int) {
        XCTAssertEqual(createSessionIdWithTokenCallCount, callCount)
    }
    
    func verifySaveAccountId(callCount: Int) {
        XCTAssertEqual(saveAccountIdCallCount, callCount)
    }
    
}
