//
//  URLSessionProtocol.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/15.
//

import Foundation

protocol URLSessionProtocol {
    func data(for request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {

}
