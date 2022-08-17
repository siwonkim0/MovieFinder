//
//  SearchTableViewController.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/08/15.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class SearchTableViewController: UIViewController, UITableViewDataSource, UISearchResultsUpdating {
    let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        setupConstraints()
        tableView.dataSource = self
    }
    
    func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        100
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var content = cell.defaultContentConfiguration()
        content.text = "hello"
        cell.contentConfiguration = content
        return cell
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text!
        self.tableView.reloadData()
    }


}
