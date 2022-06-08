//
//  APIManager.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/16.
//

import Foundation

class APIManager {
    var urlSession: URLSessionProtocol

    init(urlSession: URLSessionProtocol = URLSession.shared) {
        self.urlSession = urlSession
    }
    // MARK: - Networking
    private func performDataTask(with request: URLRequest) async throws -> Data {
        let (data, response) = try await urlSession.data(for: request, delegate: nil)
        if let httpResponse = (response as? HTTPURLResponse)?.statusCode,
           httpResponse != 200 {
            throw URLSessionError.responseFailed(code: httpResponse)
        }
        return data
    }
    
    private func decodeDataAfterDataTask<T: Decodable>(with request: URLRequest) async throws -> T {
        let data = try await performDataTask(with: request)
        guard let decodedData = JSONParser.decodeData(of: data, type: T.self) else {
            throw JSONError.dataDecodeFailed
        }
        return decodedData
    }
}

extension APIManager {
    // MARK: - CRUD
    // TODO: - Remove get from method name: async functions should avoid "get"
    func getData<T: Decodable>(from url: URL?, format type: T.Type) async throws -> T {
        guard let url = url else {
            throw URLSessionError.invaildURL
        }
        let request = URLRequest(url: url, method: .get)
        return try await decodeDataAfterDataTask(with: request)
    }
    
    func postData(_ data: Data?, to url: URL?) async throws -> Data {
        guard let url = url, let data = data else {
            throw URLSessionError.invaildURL
        }
        var request = URLRequest(url: url, method: .post)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        return try await performDataTask(with: request)
    }
    
    func postDataWithDecodingResult<T: Decodable>(_ data: Data?, to url: URL?, format type: T.Type) async throws -> T {
        guard let url = url, let data = data else {
            throw URLSessionError.invaildURL
        }
        var request = URLRequest(url: url, method: .post)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        return try await decodeDataAfterDataTask(with: request)
    }
    
    func deleteData(at url: URL?) async throws -> Data {
        guard let url = url else {
            throw URLSessionError.invaildURL
        }
        var request = URLRequest(url: url, method: .delete)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return try await performDataTask(with: request)
    }
}
