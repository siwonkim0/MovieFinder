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
    }
    
    override func prepareForReuse() {
        posterImageView.image = nil
        posterImageView.kf.cancelDownloadTask()
    }
    
    func configure(with viewModel: SearchCellViewModel) {
        guard let url = viewModel.imageUrl else {
            return
        }
        self.posterImageView.kf.setImage(
            with: url,
            options: [
                .processor(DownsamplingImageProcessor(size: CGSize(width: 60, height: 90))),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage
            ])
        self.titleLabel.text = viewModel.title
        self.decriptionLabel.text = viewModel.releaseDate
    }

}
