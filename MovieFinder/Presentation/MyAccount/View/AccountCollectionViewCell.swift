//
//  AccountCollectionViewCell.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/09/03.
//

import UIKit
import Cosmos
import Kingfisher

class AccountCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        posterImageView.layer.cornerRadius = 10
        posterImageView.layer.masksToBounds = true
        ratingView.settings.starSize = 30
        ratingView.settings.fillMode = .half
        ratingView.settings.filledColor = .systemYellow
        ratingView.settings.filledBorderColor = .systemYellow
        ratingView.settings.emptyColor = .lightGray
        ratingView.settings.emptyBorderColor = .lightGray
        ratingView.isUserInteractionEnabled = false
    }
    
    func configure(with viewModel: MovieListItem) {
        ratingView.rating = viewModel.rating
        titleLabel.attributedText = NSMutableAttributedString()
            .applyCustomFont(
                text: viewModel.title,
                fontName: "AvenirNext-Regular",
                fontSize: 15
            )
        descriptionLabel.attributedText = NSMutableAttributedString()
            .applyCustomFont(
                text: viewModel.overview,
                fontName: "AvenirNext-Regular",
                fontSize: 13
            )
        posterImageView.kf.setImage(
            with: ImageRequest(urlPath: viewModel.posterPath).urlComponents,
            options: [
                .processor(DownsamplingImageProcessor(size: CGSize(width: 60, height: 90))),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage
            ])
    }

}
