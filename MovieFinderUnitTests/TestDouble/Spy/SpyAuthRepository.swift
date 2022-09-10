//
//  SpyAuthRepository.swift
//  MovieFinderUnitTests
//
//  Created by Siwon Kim on 2022/09/01.
//

import XCTest
@testable import MovieFinder

import RxSwift

final class SpyAuthRepository: MovieAuthRepository {
    private var saveAccountIdCallCount: Int = 0
    private var makeUrlWithTokenCallCount: Int = 0
    private var createSessionIdWithTokenCallCount: Int = 0
    
    func saveAccountId() -> Observable<Data> {
        saveAccountIdCallCount += 1
        let data = Data()
        return Observable.just(data)
    }
    
    func makeUrlWithToken() -> Observable<URL> {
        makeUrlWithTokenCallCount += 1
        let url = URL(string: "url")!
        return Observable.just(url)
    }
    
    func createSessionIdWithToken() -> Observable<Void> {
        createSessionIdWithTokenCallCount += 1
        return Observable.just(())
    }
    
    func verifySaveAccountId(callCount: Int) {
        XCTAssertEqual(saveAccountIdCallCount, callCount)
    }
    
    func verifyMakeUrlWithToken(callCount: Int) {
        XCTAssertEqual(makeUrlWithTokenCallCount, callCount)
    }
    
    func verifyCreateSessionIdWithToken(callCount: Int) {
        XCTAssertEqual(createSessionIdWithTokenCallCount, callCount)
    }
    

}
