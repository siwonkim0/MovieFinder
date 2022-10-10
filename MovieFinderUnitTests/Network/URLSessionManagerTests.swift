//
//  URLSessionManagerTests.swift
//  MovieFinderUnitTests
//
//  Created by Siwon Kim on 2022/10/09.
//

import XCTest
@testable import MovieFinder

import RxSwift

final class URLSessionManagerTests: XCTestCase {
    private var disposeBag: DisposeBag!
    private var urlSessionManager: URLSessionManager!

    override func setUp() {
        disposeBag = DisposeBag()
    }
    
    override func tearDown() {
        urlSessionManager = nil
    }
    
    func test_API호출_성공시_정상적으로_디코딩되어야한다() {
        let urlSession = StubURLSession(data: StubResponse.movieList)
        urlSessionManager = URLSessionManager(urlSession: urlSession)
        
        let request = KeywordRequest(
            queryParameters: [
                "api_key": ApiKey.tmdb.description,
                "query": "super",
                "page": "1",
                "include_adult": "false"
            ]
        )
        let stubResponse = try? JSONDecoder().decode(MovieListDTO.self, from: StubResponse.movieList)
        
        let expectation = XCTestExpectation()
        urlSessionManager.performDataTask(with: request)
            .subscribe(onNext: {
                XCTAssertEqual($0.totalPages, stubResponse?.totalPages)
                expectation.fulfill()
            }).disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func test_status코드가_정상범위가_아닐때_에러메세지가_나와야한다() {
        let urlSession = StubURLSession(data: StubResponse.movieList, responseState: .invalidStatusCode)
        urlSessionManager = URLSessionManager(urlSession: urlSession)
        
        let request = KeywordRequest(
            queryParameters: [
                "api_key": ApiKey.tmdb.description,
                "query": "super",
                "page": "1",
                "include_adult": "false"
            ]
        )
        
        let expectation = XCTestExpectation()
        urlSessionManager.performDataTask(with: request)
            .subscribe(onError: {
                XCTAssertEqual("\($0)", "responseFailed(code: 400)")
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 4.0)
    }
}
