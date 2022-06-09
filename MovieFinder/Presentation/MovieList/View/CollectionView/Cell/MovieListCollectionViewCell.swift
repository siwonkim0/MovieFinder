//
//  MovieListCollectionViewCell.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/30.
//

import UIKit

class MovieListCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var posterImageView: DownloadableUIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var originalLanguageLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    
    private var viewModel: MovieListCollectionViewItemViewModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        posterImageView.image = UIImage()
        posterImageView.cancleLoadingImage()
    }
    
    func configure(with viewModel: MovieListCollectionViewItemViewModel) {
        self.viewModel = viewModel
        
        guard let posterPath = viewModel.posterPath,
              let title = viewModel.title else {
            return
        }
        self.posterImageView.getImage(with: posterPath)
        self.titleLabel.text = title
        self.originalLanguageLabel.text = viewModel.originalLanguage
        self.genresLabel.text = viewModel.genres
    }

}
