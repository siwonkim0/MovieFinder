//
//  RateRespondDTO.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/08/11.
//

import Foundation

struct RateRespondDTO: Decodable {
    let success: Bool
    let statusCode: Int?
    let statusMessage: String
    
    enum CodingKeys: String, CodingKey {
        case success
        case statusCode = "status_code"
        case statusMessage = "status_message"
    }
}
