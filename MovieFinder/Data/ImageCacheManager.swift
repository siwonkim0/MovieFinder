//
//  ImageLoader.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/26.
//

import UIKit

final class ImageCacheManager {
    static let shared = NSCache<NSString, UIImage>()
    private init() {}
}
