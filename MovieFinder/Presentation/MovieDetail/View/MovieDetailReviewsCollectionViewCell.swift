//
//  MovieDetailCommentsCollectionViewCell.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/06/21.
//

import UIKit
import Cosmos

final class MovieDetailReviewsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.userNameLabel.textColor = .white
        self.reviewLabel.textColor = .white
        reviewLabel.numberOfLines = 0
        reviewLabel.lineBreakMode = .byWordWrapping
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        reviewLabel.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 0)
        reviewLabel.sizeToFit()
        reviewLabel.frame.size = reviewLabel.bounds.size
    }
    
    func configure(with cellViewModel: MovieDetailReview) {
        self.userNameLabel.text = cellViewModel.username
        self.ratingView.rating = cellViewModel.rating * 0.5
        reviewLabel.text = cellViewModel.content
    }

}
