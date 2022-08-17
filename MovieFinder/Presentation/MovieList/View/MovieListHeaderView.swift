//
//  MovieListHeaderView.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/06/17.
//

import UIKit

final class MovieListHeaderView: UICollectionReusableView {
    lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .preferredFont(forTextStyle: .title1)
        label.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
        NSLayoutConstraint.activate([
            self.label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            self.label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 10),
            self.label.topAnchor.constraint(equalTo: self.topAnchor, constant: 15),
            self.label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 10)
        ])
    }
}
