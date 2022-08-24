//
//  SearchViewController.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/19.
//

import UIKit
import RxSwift
import RxCocoa

protocol SearchViewControllerDelegate {
    
}

final class SearchViewController: UIViewController {
    private enum Section {
        case main
    }
    
    var coordinator: SearchViewControllerDelegate?
    private let viewModel = SearchViewModel()
    private let disposeBag = DisposeBag()
    private var searchDataSource: DataSource!
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, MovieListItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, MovieListItem>
    private lazy var input = SearchViewModel.Input(
        viewWillAppear: self.rx.viewWillAppear.asObservable(),
        searchBarText: searchController.searchBar.rx.text.orEmpty.asObservable()
//        tapCancelButton: searchController.searchBar.rx.cancelButtonClicked.asObservable()
    )
    
    lazy var collectionView: UICollectionView = {
        var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        return collectionView
    }()
    
    lazy var searchController: UISearchController = {
        let resultController = SearchTableViewController()
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = resultController
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "Search Movies"
        return searchController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        configureBind()
        configureDataSource()
        configureLayout()
    }
    
    private func setView() {
        navigationItem.searchController = searchController
        definesPresentationContext = true
        view.addSubview(collectionView)
    }
    
    func configureBind() {
        let output = viewModel.transform(input)
        output.searchResultObservable
            .observe(on: MainScheduler.instance)
            .subscribe(with: self, onNext: { (self, result) in
                self.applySearchResultSnapshot(result: result)
            })
            .disposed(by: disposeBag)
    }
    
    private func applySearchResultSnapshot(result: [MovieListItem]) {
        // 검색할때마다 snapshot 생성해서 새로 apply...이게 맞나?
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(result, toSection: .main)
        searchDataSource?.apply(snapshot)
    }
    
    func configureDataSource() {
        let cellConfig = UICollectionView.CellRegistration<UICollectionViewListCell, MovieListItem> { cell, indexPath, model in
            var contentConfiguration = cell.defaultContentConfiguration()
            contentConfiguration.text = model.title
            contentConfiguration.secondaryText = model.releaseDate
            contentConfiguration.textProperties.font = .preferredFont(forTextStyle: .headline)
            cell.contentConfiguration = contentConfiguration
        }
        
        searchDataSource = DataSource(collectionView: self.collectionView) { collectionView, indexPath, model in
            return collectionView.dequeueConfiguredReusableCell(
                using: cellConfig,
                for: indexPath,
                item: model
            )
        }
    }
    
    func configureLayout() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
