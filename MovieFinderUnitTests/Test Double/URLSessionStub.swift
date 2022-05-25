//
//  URLSessionStub.swift
//  MovieFinderUnitTests
//
//  Created by Siwon Kim on 2022/05/22.
//

import Foundation
@testable import MovieFinder

class URLSessionStub: URLSessionProtocol {
    let urlSessionDataTaskStub = URLSessionDataTaskStub()
    let stubbedData: Data?
    let makeRequestFail: Bool?
    
    init(data: Data? = nil, makeRequestFail: Bool = false) {
        self.stubbedData = data
        self.makeRequestFail = makeRequestFail
    }
    
    func dataTask(with request: URLRequest,
                  completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let successResponse = HTTPURLResponse(url: request.url!,
                                              statusCode: 200,
                                              httpVersion: nil,
                                              headerFields: nil)
        let failureResponse = HTTPURLResponse(url: request.url!,
                                              statusCode: 410,
                                              httpVersion: nil,
                                              headerFields: nil)
        
        urlSessionDataTaskStub.resumeDidCall = { [weak self] in
            if self?.makeRequestFail == false {
                completionHandler(self?.stubbedData, successResponse, nil)
            } else {
                completionHandler(nil, failureResponse, nil)
            }
        }
        return urlSessionDataTaskStub
    }
}


