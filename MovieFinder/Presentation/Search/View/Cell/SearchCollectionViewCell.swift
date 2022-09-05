//
//  SearchCollectionViewCell.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/08/24.
//

import UIKit
import Kingfisher

final class SearchCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var decriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        posterImageView.layer.cornerRadius = 5
        posterImageView.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        posterImageView.image = nil
        posterImageView.kf.cancelDownloadTask()
    }
    
    func configure(with viewModel: SearchCellViewModel) {
        guard let url = viewModel.imageUrl else {
            return
        }
        posterImageView.kf.setImage(
            with: url,
            options: [
                .processor(DownsamplingImageProcessor(size: CGSize(width: 60, height: 90))),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage
            ])
        titleLabel.attributedText = NSMutableAttributedString()
            .applyCustomFont(
                text: viewModel.title,
                fontName: "AvenirNext-Regular",
                fontSize: 16
            )
        decriptionLabel.attributedText = NSMutableAttributedString()
            .applyCustomFont(
                text: "\(viewModel.originalLanguage.lowercased()) • \(viewModel.releaseDate)",
                fontName: "AvenirNext-Regular",
                fontSize: 10,
                foregroundColor: .gray
            )
    }

}
