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
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        viewModel.search(with: "Avengers")
    }
}
