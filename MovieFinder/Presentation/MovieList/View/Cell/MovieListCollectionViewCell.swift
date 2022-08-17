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
    
    private var viewModel: MovieListItemViewModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        self.posterImageView.layer.cornerRadius = 10
    }
    
    func configure(with viewModel: MovieListItemViewModel) {
        self.viewModel = viewModel
        
        guard let posterPath = viewModel.posterPath,
              let url = MovieURL.image(posterPath: posterPath).url,
              let title = viewModel.title else {
            return
        }
        self.posterImageView.kf.setImage(with: url)
        self.titleLabel.text = title
        self.originalLanguageLabel.text = viewModel.originalLanguage
        self.genresLabel.text = viewModel.genres
    }

}
