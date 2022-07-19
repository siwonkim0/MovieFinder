//
//  MovieDetailCommentsCollectionViewCell.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/06/21.
//

import UIKit
import Cosmos

class MovieDetailCommentsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    private var viewModel: MovieDetailReview!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        commentLabel.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 0)
        commentLabel.sizeToFit()
        commentLabel.frame.size = commentLabel.bounds.size
    }
    
    func configure(with viewModel: MovieDetailReview) {
        self.contentView.backgroundColor = .lightGray
        self.userNameLabel.textColor = .white
        self.commentLabel.textColor = .white
        
        self.viewModel = viewModel
        self.userNameLabel.text = viewModel.username
        self.ratingView.rating = viewModel.rating * 0.5
        showCommentPreview()
        commentLabel.numberOfLines = 0
        commentLabel.lineBreakMode = .byWordWrapping
    }
    
    func changeCommentLabelStatus() {
        if viewModel.showAllContent == false {
            commentLabel.text = viewModel.content
            viewModel.showAllContent = true
        } else {
            guard !viewModel.content.isEmpty else {
                commentLabel.text = ""
                return
            }
            showCommentPreview()
            viewModel.showAllContent = false
        }
    }
    
    private func showCommentPreview() {
        if viewModel.content.count <= 300 {
            let string = viewModel.content
            commentLabel.text = string
        } else {
            let index = viewModel.content.index(viewModel.content.startIndex, offsetBy: 300)
            let string = String(viewModel.content[...index]) + "..."
            commentLabel.text = string
        }
    }

}
