//
//  SearchViewController.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/19.
//

import UIKit

final class SearchViewController: UIViewController {
    let viewModel = SearchViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.search(with: "Avengers")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
