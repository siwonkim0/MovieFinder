//
//  MovieDetailCommentsCollectionViewCell.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/06/21.
//

import UIKit
import Cosmos

final class MovieDetailCommentsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.userNameLabel.textColor = .white
        self.commentLabel.textColor = .white
        commentLabel.numberOfLines = 0
        commentLabel.lineBreakMode = .byWordWrapping
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        commentLabel.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 0)
        commentLabel.sizeToFit()
        commentLabel.frame.size = commentLabel.bounds.size
    }
    
    func configure(with cellViewModel: MovieDetailReview) {
        self.userNameLabel.text = cellViewModel.username
        self.ratingView.rating = cellViewModel.rating * 0.5
        commentLabel.text = cellViewModel.content
    }

}
