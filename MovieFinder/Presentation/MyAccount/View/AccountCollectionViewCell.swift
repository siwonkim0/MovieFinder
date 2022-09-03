//
//  AccountCollectionViewCell.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/09/03.
//

import UIKit
import Cosmos
import Kingfisher

protocol AccountCellDelegate: AnyObject {
    func didTapRatingViewInCell(_ movie: RatedMovie)
}

final class AccountCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var ratingView: CosmosView!
    
    private var viewModel: MovieListItem?
    weak var delegate: AccountCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupPosterImageView()
        setupRatingView()
        didTapRatingView()
    }
    
    private func setupPosterImageView() {
        posterImageView.layer.cornerRadius = 10
        posterImageView.layer.masksToBounds = true
    }
    
    private func setupRatingView() {
        ratingView.settings.starSize = 30
        ratingView.settings.fillMode = .half
        ratingView.settings.filledColor = .systemYellow
        ratingView.settings.filledBorderColor = .systemYellow
        ratingView.settings.emptyColor = .lightGray
        ratingView.settings.emptyBorderColor = .lightGray
        ratingView.isUserInteractionEnabled = true
    }
    
    func configure(with viewModel: MovieListItem) {
        self.viewModel = viewModel
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
    
    func didTapRatingView() {
        ratingView.didFinishTouchingCosmos = { [weak self] rating in
            guard let self = self else { return }
            let movie = RatedMovie(movieId: self.viewModel?.id ?? 0, rating: rating)
            self.delegate?.didTapRatingViewInCell(movie)
            self.ratingView.rating = rating
        }
    }

}
