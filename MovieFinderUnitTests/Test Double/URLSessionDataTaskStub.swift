//
//  URLSessionDataTaskStub.swift
//  MovieFinderUnitTests
//
//  Created by Siwon Kim on 2022/05/24.
//

import Foundation
class URLSessionDataTaskStub: URLSessionDataTask {
    var resumeDidCall: () -> Void = {}

    override func resume() {
        resumeDidCall()
    }
}
