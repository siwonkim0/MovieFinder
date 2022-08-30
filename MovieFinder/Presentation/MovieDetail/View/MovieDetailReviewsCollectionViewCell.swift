//
//  MovieDetailReviewsCollectionViewCell.swift
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
        userNameLabel.font = UIFont(name: "AvenirNext-Regular", size: 15) ?? UIFont.boldSystemFont(ofSize: 15)
        reviewLabel.textColor = .black
        reviewLabel.font = UIFont(name: "AvenirNext-Regular", size: 15) ?? UIFont.boldSystemFont(ofSize: 15)
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
        configureUsername(with: cellViewModel)
        configureRating(with: cellViewModel)
        configureReview(with: cellViewModel)
    }
    
    private func configureUsername(with cellViewModel: MovieDetailReview) {
        let usernameText = NSMutableAttributedString()
            .applyCustomFont(
                text: cellViewModel.userName,
                fontName: "AvenirNext-Regular",
                fontSize: 15,
                foregroundColor: .gray,
                underlineStyle: NSUnderlineStyle.single.rawValue
            )
        userNameLabel.attributedText = usernameText
    }
    
    private func configureRating(with cellViewModel: MovieDetailReview) {
        self.ratingView.rating = cellViewModel.rating * 0.5
    }
    
    private func configureReview(with cellViewModel: MovieDetailReview) {
        let previewText = NSMutableAttributedString()
            .applyCustomFont(
                text: cellViewModel.content,
                fontName: "AvenirNext-Regular",
                fontSize: 15
            )
            .applyCustomFont(
                text: "...more",
                fontName: "AvenirNext-Bold",
                fontSize: 15
            )
        let allText = NSMutableAttributedString()
            .applyCustomFont(
                text: cellViewModel.content,
                fontName: "AvenirNext-Regular",
                fontSize: 15
            )
        
        if cellViewModel.showAllContent || cellViewModel.content.count <= 300  {
            reviewLabel.attributedText = allText
        } else if !cellViewModel.showAllContent && cellViewModel.content.count > 300 {
            reviewLabel.attributedText = previewText
        }
    }
    
}
