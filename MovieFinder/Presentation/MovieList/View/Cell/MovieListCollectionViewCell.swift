//
//  MovieListCollectionViewCell.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/30.
//

import UIKit
import Kingfisher

final class MovieListCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var originalLanguageLabel: UILabel!
    @IBOutlet private weak var genresLabel: UILabel!
    
    private var viewModel: MovieListCellViewModel!
    
    override func prepareForReuse() {
        posterImageView.image = nil
        posterImageView.kf.cancelDownloadTask()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = .black
        titleLabel.font = UIFont(name: "AvenirNext-Bold", size: 15) ?? UIFont.systemFont(ofSize: 15)
        originalLanguageLabel.textColor = .black
        originalLanguageLabel.font = UIFont(name: "AvenirNext-Regular", size: 10) ?? UIFont.systemFont(ofSize: 10)
        genresLabel.textColor = .black
        genresLabel.font = UIFont(name: "AvenirNext-Regular", size: 10) ?? UIFont.systemFont(ofSize: 10)
    }
    
    override func layoutSubviews() {
        posterImageView.layer.cornerRadius = 10
        posterImageView.layer.masksToBounds = true
    }
    
    func configure(with viewModel: MovieListCellViewModel) {
        self.viewModel = viewModel
        guard let url = viewModel.imageUrl else {
            return
        }
        posterImageView.kf.setImage(
            with: url,
            options: [
                .processor(DownsamplingImageProcessor(size: CGSize(width: 200, height: 300))),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage
        ])
        let cache = ImageCache.default
        cache.diskStorage.config.sizeLimit = 1000 * 1024 * 1024 //1GB
        
        titleLabel.text = viewModel.title
        originalLanguageLabel.text = viewModel.originalLanguage
        genresLabel.text = viewModel.genres
    }

}
