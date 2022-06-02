//
//  MovieListViewController.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/19.
//

import UIKit

final class MovieListViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var stackView: UIStackView!
    
    let childVC = MovieListCollectionViewController(nibName: "MovieListCollectionView", bundle: nil)
    
    let viewModel = MovieListViewModel(defaultMoviesUseCase: DefaultMoviesUseCase(moviesRepository: DefaultMoviesRepository(apiManager: APIManager())))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.getPopular()
        viewModel.getNowPlaying { posterPath in
//            try! self.childVC.view..getImage(with: posterPath.get())
        }
        viewModel.getTopRated()
        viewModel.getUpcoming()
        addChildVC()
    }
    
    func addChildVC() {
        self.addChild(childVC)
        stackView.addArrangedSubview(childVC.view)
        childVC.didMove(toParent: self)
    }
}
