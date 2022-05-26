//
//  DataConverter.swift
//  MovieFinderUnitTests
//
//  Created by Siwon Kim on 2022/05/24.
//

import Foundation

struct DataReader {
    func readLocalFile(name: String) -> Data? {
        do {
            if let bundlePath = Bundle.main.path(forResource: name, ofType: "json"),
               let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8)
                {
                return jsonData
            }
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
}
