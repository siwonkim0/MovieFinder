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
    
//    func resizedImage(at url: URL, for size: CGSize) -> UIImage? {
//        guard let imageSource = CGImageSourceCreateWithURL(url as NSURL, nil),
//            let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
//        else {
//            return nil
//        }
//
//        let context = CGContext(data: nil,
//                                width: Int(size.width),
//                                height: Int(size.height),
//                                bitsPerComponent: image.bitsPerComponent,
//                                bytesPerRow: 0,
//                                space: image.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)!,
//                                bitmapInfo: image.bitmapInfo.rawValue)
//        context?.interpolationQuality = .high
//        context?.draw(image, in: CGRect(origin: .zero, size: size))
//
//        guard let scaledImage = context?.makeImage() else { return nil }
//
//        return UIImage(cgImage: scaledImage)
//    }
    
    func downSample(at url: URL, to pointSize: CGSize, scale: CGFloat) -> UIImage {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithURL(url as NSURL, imageSourceOptions) else {
            return UIImage()
        }
        
        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
        let downsampleOptions =
        [kCGImageSourceCreateThumbnailFromImageAlways: true,
                 kCGImageSourceShouldCacheImmediately: true, //아주 중요: thumbnail 만들때 decoded imagebuffer 캐시해라는 의미
           kCGImageSourceCreateThumbnailWithTransform: true,
                  kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels] as CFDictionary
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
            return UIImage()
        }
        return UIImage(cgImage: downsampledImage)
    }
}

