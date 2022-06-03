//
//  MovieListCollectionViewCell.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/30.
//

import UIKit

class MovieListCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var starImageView: UIImageView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var originalLanguageLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(posterPath: String?,
                   rating: Double?,
                   title: String?,
                   originalLanguage: String?) {
        guard let posterPath = posterPath,
              let title = title,
              let originalLanguage = originalLanguage else {
            return
        }
        self.posterImageView.getImage(with: posterPath)
        self.ratingLabel.text = "\(rating)"
        self.titleLabel.text = title
        self.originalLanguageLabel.text = originalLanguage
        //TODO: Genere
    }

}
