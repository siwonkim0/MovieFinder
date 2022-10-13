//
//  KeyChainError.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/10/13.
//

import Foundation

enum KeychainError: LocalizedError {
    case failedToSave
    case itemNotFound
    case unexpectedStatus(OSStatus)
    case noResult
    case failedToConvertToData
    case failedToGetSessionID
    case failedToGetAccountID
}

extension KeychainError {
    var errorDescription: String? {
        switch self {
        case .failedToSave:
            return "Failed to save data"
        case .itemNotFound:
            return "Failed to get data"
        case let .unexpectedStatus(status):
            return "Unexpected Status: \(status)"
        case .noResult:
            return "Result not found"
        case .failedToConvertToData:
            return "Failed to convert result to data"
        case .failedToGetAccountID:
            return "Failed to get account id"
        case .failedToGetSessionID:
            return "Failed to get session id"
        }
    }
}
