//
//  JSONParser.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/14.
//

import Foundation

enum JSONParser {
    
    static func decodeData<T: Decodable>(of JSON: Data, type: T.Type) -> T? {
        let decoder = JSONDecoder()
        
        var decodedData: T?
        do {
            decodedData = try decoder.decode(type, from: JSON)
        } catch DecodingError.keyNotFound(let key, let context) {
            print("could not find key \(key) in JSON: \(context.debugDescription)")
        } catch DecodingError.valueNotFound(let type, let context) {
            print("could not find type \(type) in JSON: \(context.debugDescription)")
        } catch DecodingError.typeMismatch(let type, let context) {
            print("type mismatch for type \(type) in JSON: \(context.debugDescription)")
        } catch DecodingError.dataCorrupted(let context) {
            print("data found to be corrupted in JSON: \(context.debugDescription)")
        } catch let error as NSError {
            NSLog("Error in read(from:ofType:) domain= \(error.domain), description= \(error.localizedDescription)")
        }
        
        return decodedData
    }
}
