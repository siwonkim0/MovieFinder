//
//  MovieListViewController.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/19.
//

import UIKit

final class MovieListViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    let viewModel = MovieListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.getPopular()
        viewModel.getNowPlaying { url in
            try! self.imageView.setImageUrl(url.get())
        }
        viewModel.getTopRated()
        viewModel.getUpcoming()
    }
}
