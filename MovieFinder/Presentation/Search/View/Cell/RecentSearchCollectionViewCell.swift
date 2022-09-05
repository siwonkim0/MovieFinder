//
//  RecentSearchCollectionViewCell.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/08/17.
//

import UIKit
import SnapKit

final class RecentSearchCollectionViewCell: UICollectionViewCell {
    private let posterImageView: UIImageView = {
        let poster = UIImageView()
        poster.layer.cornerRadius = 5
        return poster
    }()
    
    private let titleLabel: UILabel = {
        let title = UILabel()
        title.text = "title"
        return title
    }()
    
    private let genresLabel: UILabel = {
        let genres = UILabel()
        genres.text = "genres"
        return genres
    }()
    
    private let overviewLabel: UILabel = {
        let overview = UILabel()
        overview.text = "overview"
        return overview
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setLayout() {
        let labelStackView = UIStackView(arrangedSubviews: [titleLabel, genresLabel, overviewLabel])
        labelStackView.axis = .vertical
        posterImageView.setContentHuggingPriority(.init(rawValue: 255), for: .horizontal)
        let entireStackView = UIStackView(arrangedSubviews: [posterImageView, labelStackView])
        entireStackView.distribution = .fillEqually
        contentView.addSubview(entireStackView)
        
        entireStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
