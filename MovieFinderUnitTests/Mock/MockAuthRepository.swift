//
//  MockAuthRepository.swift
//  MovieFinderUnitTests
//
//  Created by Siwon Kim on 2022/09/01.
//

import XCTest
@testable import MovieFinder

import RxSwift

final class MockAuthRepository: MovieAuthRepository {
    private var saveAccountIdCallCount: Int = 0
    private var makeUrlWithTokenCallCount: Int = 0
    private var createSessionIdWithTokenCallCount: Int = 0
    
    func saveAccountId() -> Observable<Data> {
        let data = Data()
        return Observable.just(data)
    }
    
    func makeUrlWithToken() -> Observable<URL> {
        let url = URL(string: "url")!
        return Observable.just(url)
    }
    
    func createSessionIdWithToken() -> Observable<Void> {
        return Observable.just(())
    }
    
    func verifySaveAccountId(callCount: Int) {
        saveAccountIdCallCount += 1
        XCTAssertEqual(saveAccountIdCallCount, callCount)
    }
    
    func verifyMakeUrlWithToken(callCount: Int) {
        makeUrlWithTokenCallCount += 1
        XCTAssertEqual(makeUrlWithTokenCallCount, callCount)
    }
    
    func verifyCreateSessionIdWithToken(callCount: Int) {
        createSessionIdWithTokenCallCount += 1
        XCTAssertEqual(createSessionIdWithTokenCallCount, callCount)
    }
    

}
