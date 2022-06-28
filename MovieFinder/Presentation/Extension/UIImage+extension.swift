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
    
}
