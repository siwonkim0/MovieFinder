//
//  SearchCollectionViewCell.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/08/24.
//

import UIKit
import Kingfisher

class SearchCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var decriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        posterImageView.image = nil
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
                .cacheMemoryOnly
            ])
        self.titleLabel.text = viewModel.title
        self.decriptionLabel.text = viewModel.releaseDate
    }

}
