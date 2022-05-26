//
//  UIImageView+extension.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/26.
//

import UIKit

extension UIImageView {
    func getImage(with posterPath: String) {
        guard let urlString = MovieURL.image(posterPath: posterPath).url?.absoluteString else {
            return
        }
        let cacheKey = NSString(string: urlString)
        if let cachedImage = ImageCacheManager.shared.object(forKey: cacheKey) {
            self.image = cachedImage
            return
        }
        DispatchQueue.global(qos: .background).async {
            if let imageUrl = URL(string: urlString) {
                URLSession.shared.dataTask(with: imageUrl) { data, response, error in
                    if let _ = error {
                        DispatchQueue.main.async {
                            self.image = UIImage()
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        if let data = data, let image = UIImage(data: data) {
                            ImageCacheManager.shared.setObject(image, forKey: cacheKey)
                            self.image = image
                        }
                    }
                }.resume()
            }
        }
    }
 }
