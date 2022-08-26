//
//  NSMutableAttributedString+extension.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/08/26.
//

import UIKit

extension NSMutableAttributedString {
    
    func applyCustomFont(
        text: String,
        fontName: String,
        fontSize: CGFloat,
        foregroundColor: UIColor? = nil,
        backgroundColor: UIColor? = nil,
        underlineStyle: Int? = nil //NSUnderlineStyle.single.rawValue
    ) -> NSMutableAttributedString {
        var attributes: [NSAttributedString.Key : Any] = [
            .font : UIFont(name: fontName, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize),
            .foregroundColor : foregroundColor ?? UIColor.black,
            .backgroundColor : backgroundColor ?? UIColor.clear,
        ]
        
        if let underlineStyle = underlineStyle {
            attributes[.underlineStyle] = underlineStyle
        }
        
        self.append(NSAttributedString(string: text, attributes: attributes))
        return self
    }
    
}
