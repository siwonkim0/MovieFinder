//
//  MovieListHeaderView.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/06/17.
//

import UIKit

final class MovieListHeaderView: UICollectionReusableView {
    let label: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont(name: "AvenirNext-Bold", size: 20) ?? UIFont.systemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
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
            make.trailing.bottom.equalToSuperview().offset(10)
            make.top.leading.equalToSuperview().offset(15)
        }
    }
}
