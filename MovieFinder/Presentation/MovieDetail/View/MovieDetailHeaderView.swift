//
//  MovieDetailHeaderView.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/06/21.
//

import UIKit
import SnapKit

final class MovieDetailHeaderView: UICollectionReusableView {
    lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(label)
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not Implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        initialize()
    }
    
    func initialize() {
        self.label.text = nil
    }
    
    func setConstraints() {
        self.label.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview().inset(10)
            make.leading.equalToSuperview().inset(3)
            make.top.equalToSuperview().inset(15)
        }
    }
}
