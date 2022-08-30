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
        plotSummaryTextView.textColor = .black
        plotSummaryTextView.backgroundColor = .clear
    }
    
    func configure(with viewModel: MovieDetailBasicInfo) {
        self.viewModel = viewModel
        plotSummaryTextView.text = viewModel.plot
    }

}
