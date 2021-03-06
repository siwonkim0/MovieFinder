//
//  KeychainManager.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/19.
//

import Foundation

final class KeychainManager {
    enum KeychainError: Error {
        case failedToSave
        case itemNotFound
        case unexpectedStatus(OSStatus)
        case invalidItemFormat
    }
    
    var isExisting: Bool = false
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
    func read(service: String, account: String) throws -> Data? {
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
        
        return result as? Data
    }
    
    func delete(service: String, account: String) throws {
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
    
    func checkExistingSession() {
        do {
            try read(service: "TMDB", account: "access token")
            isExisting = true
        } catch {
            print("No existing Session ID")
        }
    }
    
    func getSessionID() -> String {
        var result: String = ""
        do {
            let data = try read(service: "TMDB", account: "access token")
            result = String(decoding: data!, as: UTF8.self)
            print(result)
        } catch {
            print("Failed to read Session ID")
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
            print("Failed to delete Session ID")
        }
    }
}
