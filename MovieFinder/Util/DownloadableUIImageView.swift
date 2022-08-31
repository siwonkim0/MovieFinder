//
//  DownloadableUIImageView.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/26.
//

import UIKit

final class DownloadableUIImageView: UIImageView {
    private var dataTask: URLSessionDataTask?
    
    func getImage(with url: URL?) {
        self.image = UIImage()
        self.layer.cornerRadius = CGFloat(15)

        guard let urlString = url?.absoluteString else {
            return
        }
        let cacheKey = NSString(string: urlString)
        if let cachedImage = ImageCacheManager.shared.object(forKey: cacheKey) {
            self.image = cachedImage
            return
        }
        
        if let imageUrl = URL(string: urlString) {
            let urlRequest = URLRequest(url: imageUrl, cachePolicy: .returnCacheDataElseLoad)
            dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                if let _ = error {
                    DispatchQueue.main.async {
                        self.image = UIImage()
                    }
                    return
                }
                DispatchQueue.main.async {
                    if let data = data, let image = UIImage(data: data)?.resize(newWidth: 310) {
                        ImageCacheManager.shared.setObject(image, forKey: cacheKey)
                        self.image = image
                    }
                }
            }
            dataTask?.resume()
        }
    }
    
    func cancelLoadingImage() {
        dataTask?.cancel()
        dataTask = nil
    }
}
