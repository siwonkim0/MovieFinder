//
//  SectionBackgroundDecorationView.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/06/22.
//

import UIKit

final class SectionBackgroundDecorationView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .black
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
