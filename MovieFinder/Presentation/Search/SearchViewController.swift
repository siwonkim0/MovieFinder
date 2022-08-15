//
//  SearchViewController.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/19.
//

import UIKit

protocol SearchViewControllerDelegate {
    
}

final class SearchViewController: UIViewController {
    let viewModel = SearchViewModel()
    var coordinator: SearchViewControllerDelegate?
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView()
        return collectionView
    }()
    
    lazy var searchController: UISearchController = {
        let resultController = SearchTableViewController()
        let searchController = UISearchController(searchResultsController: resultController)
        searchController.searchResultsUpdater = resultController
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "Search Movies"
        return searchController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
}
