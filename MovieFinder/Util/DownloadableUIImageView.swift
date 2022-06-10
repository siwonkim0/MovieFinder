//
//  DownloadableUIImageView.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/26.
//

import UIKit

class DownloadableUIImageView: UIImageView {
    var dataTask: URLSessionDataTask?
    
    func getImage(with posterPath: String) {
        guard let urlString = MovieURL.image(posterPath: posterPath).url?.absoluteString else {
            return
        }
        let cacheKey = NSString(string: urlString)
        if let cachedImage = ImageCacheManager.shared.object(forKey: cacheKey) {
            self.image = cachedImage
            return
        }
        
        self.image = UIImage()
        if let imageUrl = URL(string: urlString) {
            let urlRequest = URLRequest(url: imageUrl, cachePolicy: .returnCacheDataElseLoad)
            self.dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
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
            }
            self.dataTask?.resume()
        }
    }
    
    func cancleLoadingImage() {
        dataTask?.cancel()
        dataTask = nil
    }
}
