//
//  MockAuthUseCase.swift
//  MovieFinderUnitTests
//
//  Created by Siwon Kim on 2022/09/02.
//

import XCTest
@testable import MovieFinder

import RxSwift

final class MockAuthUseCase: MoviesAuthUseCase {
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
    
    func verifyGetUrlWithTokenCallCount() {
        XCTAssertEqual(getUrlWithTokenCallCount, 1)
    }
    
    func verifyCreateSessionIdWithTokenCallCount() {
        XCTAssertEqual(createSessionIdWithTokenCallCount, 1)
    }
    
    func verifySaveAccountIdCallCount() {
        XCTAssertEqual(saveAccountIdCallCount, 1)
    }
    
}
