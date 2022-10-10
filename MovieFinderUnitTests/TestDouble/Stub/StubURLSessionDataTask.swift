//
//  StubURLSessionDataTask.swift
//  MovieFinderUnitTests
//
//  Created by Siwon Kim on 2022/05/24.
//

@testable import MovieFinder

import Foundation

class StubURLSessionDataTask: URLSessionDataTask {
    var resumeDidCall: () -> Void = {}

    override func resume() {
        resumeDidCall()
    }
}
