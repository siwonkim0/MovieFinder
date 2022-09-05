//
//  URLSessionProtocol.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/15.
//

import Foundation

protocol URLSessionProtocol {
    func dataTask(with request: URLRequest,
    completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

extension URLSession: URLSessionProtocol {

}
