//
//  SearchCollectionViewCell.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/08/24.
//

import UIKit
import Kingfisher

class SearchCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var decriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(with viewModel: SearchCellViewModel) {
        guard let url = viewModel.imageUrl else {
            return
        }
        let serialQueue = DispatchQueue(label: "Decode queue")
        serialQueue.async {
            let downsampled = UIImage().downSample(at: url, to: CGSize(width: 60, height: 80), scale: 1)
            DispatchQueue.main.async {
                self.posterImageView.image = downsampled
            }
        }
        self.titleLabel.text = viewModel.title
        self.decriptionLabel.text = viewModel.releaseDate
    }

}
