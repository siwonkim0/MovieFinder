//
//  OriginalLanguage.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/09/03.
//

import Foundation

enum OriginalLanguage: String, Hashable {
    case english = "en"
    case turkish = "tr"
    case spanish = "es"
    case french = "fr"
    case latin = "la"
    case hindi = "hi"
    case japanese = "ja"
    case korean = "ko"
    case thai = "th"
    
    init?(rawValue: String) {
        switch rawValue {
        case "en":
            self = .english
        case "tr":
            self = .turkish
        case "es":
            self = .spanish
        case "fr":
            self = .french
        case "la":
            self = .latin
        case "hi":
            self = .hindi
        case "ja":
            self = .japanese
        case "ko":
            self = .korean
        case "th":
            self = .thai
        default:
            return nil
        }
    }
    
    var formatted: String {
        switch self {
        case .english:
            return "ENGLISH"
        case .turkish:
            return "TURKISH"
        case .spanish:
            return "SPANISH"
        case .french:
            return "FRENCH"
        case .latin:
            return "LATIN"
        case .hindi:
            return "HINDI"
        case .japanese:
            return "JAPANESE"
        case .korean:
            return "KOREAN"
        case .thai:
            return "THAI"
        }
    }
}
