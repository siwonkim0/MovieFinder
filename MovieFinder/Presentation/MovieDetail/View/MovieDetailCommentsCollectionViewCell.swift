//
//  MovieDetailCommentsCollectionViewCell.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/06/21.
//

import UIKit

class MovieDetailCommentsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var commentTextView: UITextView!
    private var viewModel: MovieDetailReview!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setUp() {
        
    }
    
    func configure(with viewModel: MovieDetailReview) {
        self.userNameLabel.textColor = .white
        self.commentTextView.textColor = .white
        commentTextView.backgroundColor = .blue
        
        self.viewModel = viewModel
        self.userNameLabel.text = viewModel.username
        self.commentTextView.text = viewModel.content
    }

}
