//
//  MovieFinderUnitTests.swift
//  MovieFinderUnitTests
//
//  Created by Siwon Kim on 2022/05/21.
//

import XCTest
@testable import MovieFinder

class MovieFinderUnitTests: XCTestCase {
    var sut: APIManager!
    let networkChecker = NetworkChecker.shared
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = APIManager()
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    func test_GetApiCallGetsHTTPStatusCode200() throws {
        try XCTSkipUnless(networkChecker.isConnected, "Network connectivity needed for this test")
        let url = MovieURL.token.url
        let promise = expectation(description: "Status code: 200")
        
        sut.getData(from: url, format: Token.self) { result in
            switch result {
            case .success(_):
                promise.fulfill()
            case .failure(let error):
                XCTFail("\(error)")
            }
        }
        wait(for: [promise], timeout: 5)
    }
    
    func test_GetImageApiCallGetsHTTPStatusCode200() throws {
        try XCTSkipUnless(networkChecker.isConnected, "Network connectivity needed for this test")
        let url = MovieURL.image(posterPath: "2tOgiY533JSFp7OrVlkeRJvsZpI.jpg").url
        let promise = expectation(description: "Status code: 200")
        
        sut.getImage(with: url) { result in
            switch result {
            case .success(_):
                promise.fulfill()
            case .failure(let error):
                XCTFail("\(error)")
            }
        }
        wait(for: [promise], timeout: 1)
    }
    
    func test_PostApiCallGetsHTTPStatusCode200() throws {
        try XCTSkipUnless(networkChecker.isConnected, "Network connectivity needed for this test")
        let jsonData = JSONParser.encodeToData(with: RateDTO(value: 4.5))
        let sessionID = KeychainManager.shared.getSessionID()
        let url = MovieURL.rateMovie(sessionID: sessionID, movieID: 284052).url
        let promise = expectation(description: "Status code: 200")
        
        sut.postData(jsonData, to: url) { result in
            switch result {
            case .success(_):
                promise.fulfill()
            case .failure(let error):
                XCTFail("\(error)")
            }
        }
        wait(for: [promise], timeout: 5)
    }
    
    func test_DeleteApiCallGetsHTTPStatusCode200() throws {
        try XCTSkipUnless(networkChecker.isConnected, "Network connectivity needed for this test")
        let sessionID = KeychainManager.shared.getSessionID()
        let url = MovieURL.deleteRating(sessionID: sessionID, movieID: 284052).url
        let promise = expectation(description: "Status code: 200")
        
        sut.deleteData(at: url) { result in
            switch result {
            case .success(_):
                promise.fulfill()
            case .failure(let error):
                XCTFail("\(error)")
            }
        }
        wait(for: [promise], timeout: 5)
    }
}
