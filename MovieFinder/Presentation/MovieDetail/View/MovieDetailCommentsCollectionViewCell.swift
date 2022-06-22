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
    
    func configure(with viewModel: MovieDetailReview) {
        self.viewModel = viewModel
        
        self.userNameLabel.text = viewModel.username
        self.commentLabel.text = viewModel.content
    }

}
