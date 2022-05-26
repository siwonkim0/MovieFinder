//
//  MovieFinderFakeTests.swift
//  
//
//  Created by Siwon Kim on 2022/05/21.
//

import XCTest
@testable import MovieFinder

class MovieFinderFakeTests: XCTestCase {
    var sut: APIManager!
    var dataConverter = DataReader()
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = APIManager(urlSession: URLSessionStub())
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    func test_GetDataCorrectlyParsesJSONDataToModel() {
        let stubbedData = dataConverter.readLocalFile(name: "MovieDetailData")
        let movieDetailUrl = MovieURL.details(id: 271110, language: Language.english.value).url!
        
        let urlSessionStub = URLSessionStub(data: stubbedData, makeRequestFail: false)
        sut.urlSession = urlSessionStub
        
        let promise = expectation(description: "Value Received")
        
        sut.getData(from: movieDetailUrl, format: TMDBMovieDetail.self) { result in
            switch result {
            case .success(let movieDetail):
                XCTAssertEqual(movieDetail.title, "Captain America: Civil War")
                promise.fulfill()
            case .failure(let error):
                XCTFail("\(error)")
            }
        }
        wait(for: [promise], timeout: 1)
    }


}
