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
    
    let viewModel: MovieListViewModel
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildVC()
    }
    
    init?(viewModel: MovieListViewModel, coder: NSCoder) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addChildVC() {
        viewModel.collectionViewModels.forEach { collectionViewModel in
            let childVC = MovieListCollectionViewController(viewModel: collectionViewModel, nibName: "MovieListCollectionView", bundle: nil)
            self.addChild(childVC)
            stackView.addArrangedSubview(childVC.view)
            childVC.didMove(toParent: self)
        }
    }
}
