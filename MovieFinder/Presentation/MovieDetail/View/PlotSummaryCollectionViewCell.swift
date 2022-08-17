//
//  PlotSummaryCollectionViewCell.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/06/24.
//

import UIKit

final class PlotSummaryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var plotSummaryTextView: UITextView!
    var viewModel: MovieDetailBasicInfo!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(with viewModel: MovieDetailBasicInfo) {
        self.plotSummaryTextView.textColor = .white
        plotSummaryTextView.backgroundColor = .clear
        
        self.viewModel = viewModel
        plotSummaryTextView.text = viewModel.plot
    }

}
