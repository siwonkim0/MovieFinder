//
//  MovieListViewController.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/19.
//

import UIKit

final class MovieListViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    let viewModel = MovieListViewModel(defaultMoviesUseCase: DefaultMoviesUseCase(moviesRepository: DefaultMoviesRepository(apiManager: APIManager())))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.getPopular()
        viewModel.getNowPlaying { posterPath in
            try! self.imageView.getImage(with: posterPath.get())
        }
        viewModel.getTopRated()
        viewModel.getUpcoming()
    }
}
