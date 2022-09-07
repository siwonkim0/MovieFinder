//
//  BasicInfoCollectionViewCell.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/09/07.
//

import UIKit
import Cosmos
import Kingfisher

class BasicInfoCollectionViewCell: UICollectionViewCell {
    private let posterImageView: UIImageView = {
        let posterImageView = UIImageView()
        posterImageView.layer.masksToBounds = true
        posterImageView.layer.cornerRadius = 20
        posterImageView.kf.indicatorType = .activity
        return posterImageView
    }()
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textColor = .black
        titleLabel.font = UIFont(name: "AvenirNext-Bold", size: 30) ?? UIFont.systemFont(ofSize: 30)
        titleLabel.adjustsFontSizeToFitWidth = true
        return titleLabel
    }()
    
    private let descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.textColor = .black
        descriptionLabel.font = UIFont(name: "AvenirNext-Regular", size: 15) ?? UIFont.systemFont(ofSize: 15)
        descriptionLabel.adjustsFontSizeToFitWidth = true
        return descriptionLabel
    }()
    
    private let averageRatingLabel: UILabel = {
        let averageRatingLabel = UILabel()
        averageRatingLabel.textColor = .black
        averageRatingLabel.font = UIFont(name: "AvenirNext-Regular", size: 15) ?? UIFont.systemFont(ofSize: 15)
        averageRatingLabel.adjustsFontSizeToFitWidth = true
        return averageRatingLabel
    }()
    
    private let ratingView: CosmosView = {
        let ratingView = CosmosView()
        ratingView.rating = 0
        ratingView.settings.fillMode = .half
        ratingView.settings.filledColor = .systemYellow
        ratingView.settings.emptyColor = .lightGray
        ratingView.settings.emptyBorderColor = .lightGray
        ratingView.settings.starSize = 30
        return ratingView
    }()

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with model: BasicInfoCellViewModel) {
        configureImageView(with: model.url)
        titleLabel.text = model.title
        descriptionLabel.text = model.description
        averageRatingLabel.text = model.averageRating
    }
    
    private func configureImageView(with url: URL?) {
        guard let url = url else {
            return
        }
        let processor = DownsamplingImageProcessor(size: CGSize(width: 368, height: 500))
        posterImageView.kf.setImage(
            with: url,
            placeholder: UIImage(),
            options: [
                .transition(.fade(1)),
                .forceTransition,
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage
            ],
            completionHandler: nil
        )
    }

    private func setLayout() {
        let descriptionStackView = UIStackView(
            arrangedSubviews: [
                posterImageView,
                titleLabel,
                descriptionLabel,
                averageRatingLabel,
                ratingView
            ])
        contentView.addSubview(descriptionStackView)
        
        posterImageView.setContentHuggingPriority(.init(rawValue: 200), for: .vertical)
        posterImageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(500)
        }
        
        descriptionStackView.axis = .vertical
        descriptionStackView.alignment = .center
        descriptionStackView.distribution = .equalSpacing
        descriptionStackView.spacing = 10
        
        descriptionStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
