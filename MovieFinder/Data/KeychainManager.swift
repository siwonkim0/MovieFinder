//
//  KeychainManager.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/19.
//

import Foundation
import RxSwift

final class KeychainManager {
    enum KeychainError: Error {
        case failedToSave
        case itemNotFound
        case unexpectedStatus(OSStatus)
        case invalidItemFormat
        case noResult
        case failedToConvertToData
    }
    
    var isSessionIdExisting: Bool = false
    static let shared = KeychainManager()
    private init() { }
    
    func save(data: Data, service: String, account: String) throws {
        let query: [String: AnyObject] = [
            kSecValueData as String: data as AnyObject,
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status != errSecSuccess {
            print("Error: \(status)")
            let statusString = SecCopyErrorMessageString(status, nil) as? String
            print(statusString!)
            throw KeychainError.failedToSave
        }
    }
    
    @discardableResult
    private func read(service: String, account: String) throws -> Data {
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecReturnData as String: kCFBooleanTrue,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status != errSecItemNotFound else {
            throw KeychainError.itemNotFound
        }
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
        guard let result = result else {
            throw KeychainError.noResult
        }
        guard let resultData = result as? Data else {
            throw KeychainError.failedToConvertToData
        }
        return resultData
    }
    
    private func delete(service: String, account: String) throws {
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
        ]
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
    
    //MARK: - Session ID
    func checkExistingSession() {
        do {
            try read(service: "TMDB", account: "access token")
            isSessionIdExisting = true
        } catch {
            print("No existing session ID")
        }
    }
    
    func getSessionID() -> String {
        var result: String = ""
        do {
            let data = try read(service: "TMDB", account: "access token")
            result = String(decoding: data, as: UTF8.self)
        } catch {
            print("Failed to read session ID")
        }
        return result
    }
    
    func deleteExistingSession() {
        do {
            try KeychainManager.shared.delete(
                service: "TMDB",
                account: "access token"
            )
            print("delete succeeded")
        } catch {
            print("Failed to delete session ID")
        }
    }
    
    //MARK: - Account ID
    func getAccountID() -> Int {
        var result: Int = 0
        do {
            let data = try read(service: "TMDB", account: "account ID")
            result = Int(String(decoding: data, as: UTF8.self)) ?? 0
        } catch {
            print("Failed to read account ID")
        }
        return result
    }
    
    func deleteAccountId() {
        do {
            try KeychainManager.shared.delete(
                service: "TMDB",
                account: "account ID"
            )
            print("delete succeeded")
        } catch {
            print("Failed to delete account ID")
        }
    }
}
