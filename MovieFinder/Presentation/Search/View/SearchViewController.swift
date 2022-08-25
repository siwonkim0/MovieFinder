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
    private let viewModel: SearchViewModel
    private let disposeBag = DisposeBag()
    private var searchDataSource: DataSource!
    let cancelButtonClicked = PublishSubject<Void>()
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, SearchCellViewModel>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, SearchCellViewModel>
    private lazy var input = SearchViewModel.Input(
        viewWillAppear: self.rx.viewWillAppear.asObservable(),
        searchBarText: searchController.searchBar.rx.text.orEmpty.asObservable(),
        searchCancelled: searchController.searchBar.rx.cancelButtonClicked.asObservable()
    )
    
    lazy var collectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: view.frame.width - CGFloat(40), height: 110)
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 1.0
        
        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        return collectionView
    }()
    
    lazy var searchController: UISearchController = {
        let resultController = SearchTableViewController()
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Movies"
        definesPresentationContext = true
        return searchController
    }()
    
    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    init?(viewModel: SearchViewModel, coder: NSCoder) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        output.searchCancelledObservable
            .observe(on: MainScheduler.instance)
            .subscribe(with: self, onNext: { (self, result) in
                self.applySearchResultSnapshot(result: result)
            })
            .disposed(by: disposeBag)
    }
    
    private func applySearchResultSnapshot(result: [SearchCellViewModel]) {
        // 검색할때마다 snapshot 생성해서 새로 apply...이게 맞나?
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(result, toSection: .main)
        searchDataSource?.apply(snapshot)
    }
    
    func configureDataSource() {
        collectionView.registerCell(withNib: SearchCollectionViewCell.self)
        searchDataSource = DataSource(collectionView: self.collectionView) { collectionView, indexPath, model in
            let cell = collectionView.dequeueReusableCell(
                withClass: SearchCollectionViewCell.self,
                indexPath: indexPath
            )
            cell.configure(with: model)
            return cell
        }
    }
    
    func configureLayout() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
// MARK: - UISearchBarDelegate
extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if !searchController.isActive {
                print("Cancelled")
            }
        cancelButtonClicked.onNext(())
    }

}
