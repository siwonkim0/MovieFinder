//
//  StubURLSession.swift
//  MovieFinderUnitTests
//
//  Created by Siwon Kim on 2022/05/22.
//
@testable import MovieFinder

import Foundation

class StubURLSession: URLSessionProtocol {
    enum ResponseState {
        case success
        case invalidStatusCode
        case invalidData
    }
    
    var dataTask: StubURLSessionDataTask?
    let stubbedData: Data?
    var responseState: ResponseState = .success
    
    init(data: Data? = nil, responseState: ResponseState = .success) {
        self.stubbedData = data
        self.responseState = responseState
    }
    
    func dataTask(with request: URLRequest,
                  completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let successResponse = HTTPURLResponse(url: request.url!,
                                              statusCode: 200,
                                              httpVersion: "1.1",
                                              headerFields: nil)
        let failureResponse = HTTPURLResponse(url: request.url!,
                                              statusCode: 400,
                                              httpVersion: "1.1",
                                              headerFields: nil)
        
        let dataTask = StubURLSessionDataTask()
        self.dataTask = dataTask
        
        dataTask.resumeDidCall = {
            switch self.responseState {
            case .success:
                completionHandler(self.stubbedData, successResponse, nil)
            case .invalidStatusCode:
                completionHandler(nil, failureResponse, nil)
            case .invalidData:
                completionHandler(nil, successResponse, nil)
            }
        }
        return dataTask
    }
}


