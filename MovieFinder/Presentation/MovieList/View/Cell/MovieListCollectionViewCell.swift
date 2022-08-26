//
//  MovieListCollectionViewCell.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/30.
//

import UIKit
import Kingfisher

final class MovieListCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var originalLanguageLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    
    private var viewModel: MovieListCellViewModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabel.textColor = .black
        self.titleLabel.font = UIFont(name: "AvenirNext-Bold", size: 15) ?? UIFont.systemFont(ofSize: 15)
        self.originalLanguageLabel.textColor = .black
        self.originalLanguageLabel.font = UIFont(name: "AvenirNext-Regular", size: 10) ?? UIFont.systemFont(ofSize: 10)
        self.genresLabel.textColor = .black
        self.genresLabel.font = UIFont(name: "AvenirNext-Regular", size: 10) ?? UIFont.systemFont(ofSize: 10)
    }
    
    override func layoutSubviews() {
        self.posterImageView.layer.cornerRadius = 10
    }
    
    func configure(with viewModel: MovieListCellViewModel) {
        self.viewModel = viewModel
        guard let url = viewModel.imageUrl else {
            return
        }
        self.posterImageView.kf.setImage(
            with: url,
            options: [
                .processor(DownsamplingImageProcessor(size: CGSize(width: 200, height: 300))),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage
        ])
        self.titleLabel.text = viewModel.title
        self.originalLanguageLabel.text = viewModel.originalLanguage
        self.genresLabel.text = viewModel.genres
    }

}
