//
//  MovieDetailCommentsCollectionViewCell.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/06/21.
//

import UIKit

class MovieDetailCommentsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
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
        self.userNameLabel.textColor = .white
        self.commentLabel.textColor = .white
        commentLabel.backgroundColor = .blue
        
        self.viewModel = viewModel
        self.userNameLabel.text = viewModel.username
        showCommentPreview()
        commentLabel.numberOfLines = 0
        commentLabel.lineBreakMode = .byWordWrapping
    }
    
    func changeCommentLabelStatus() {
//        let newSize = commentLabel.intrinsicContentSize
//        commentLabel.frame.size = newSize
//        commentLabel.sizeToFit()
//        commentLabel.adjustsFontSizeToFitWidth = true
//        commentLabel.adjustsFontForContentSizeCategory = true
        if viewModel.showAllContent == false {
            commentLabel.text = viewModel.content
            viewModel.showAllContent = true
            setNeedsLayout()
            print(viewModel.content)
            print("AA")
        } else {
            showCommentPreview()
            print("BB")
            viewModel.showAllContent = false
            setNeedsLayout()
        }
    }
    
    private func showCommentPreview() {
        let index = viewModel.content.index(viewModel.content.startIndex, offsetBy: 300)
        let string = String(viewModel.content[...index]) + "..."
        commentLabel.text = string
        print(string)
    }

}
