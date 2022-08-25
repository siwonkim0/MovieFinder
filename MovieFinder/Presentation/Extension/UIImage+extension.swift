//
//  UIImage+extension.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/06/28.
//

import UIKit

extension UIImage {
    func resize(newWidth: CGFloat) -> UIImage {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale

        let newSize = CGSize(width: newWidth, height: newHeight)
        let render = UIGraphicsImageRenderer(size: newSize)
        let renderImage = render.image { context in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
        
        print("origin: \(self), resize: \(renderImage)")
        return renderImage
    }
    
    func downSample(at url: URL, to pointSize: CGSize, scale: CGFloat) -> UIImage {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithURL(url as NSURL, imageSourceOptions) else {
            return UIImage()
        }
        
        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
        ] as CFDictionary
        
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
            return UIImage()
        }
        return UIImage(cgImage: downsampledImage)
    }
}

