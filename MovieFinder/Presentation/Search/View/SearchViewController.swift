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
    func showDetailViewController(at viewController: UIViewController, of id: Int)
}

final class SearchViewController: UIViewController {
    private enum Section {
        case main
    }
    
    var coordinator: SearchViewControllerDelegate?
    private let viewModel: SearchViewModel
    private let disposeBag = DisposeBag()
    private var searchDataSource: DataSource!
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, SearchCellViewModel>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, SearchCellViewModel>
    
    private lazy var collectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: view.frame.width - CGFloat(40), height: 110)
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 1.0
        
        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        return collectionView
    }()
    
    private lazy var searchController: UISearchController = {
        let resultController = SearchTableViewController()
        let searchController = UISearchController(searchResultsController: nil)
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
        didSelectItem()
    }
    
    private func setView() {
        navigationItem.searchController = searchController
        view.addSubview(collectionView)
    }
    
    private func configureBind() {
        let input = SearchViewModel.Input(
            searchBarText: searchController.searchBar.rx.text.orEmpty.asObservable(),
            searchCancelled: searchController.searchBar.rx.cancelButtonClicked.asObservable(),
            loadMoreContent: contentOffset()
        )
        
        let output = viewModel.transform(input)
        output.searchResults
            .drive(with: self, onNext: { (self, result) in
                self.applySearchResultSnapshot(result: result)
            })
            .disposed(by: disposeBag)
    }
    
    private func applySearchResultSnapshot(result: [SearchCellViewModel]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(result, toSection: .main)
        searchDataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    private func configureDataSource() {
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
    
    private func configureLayout() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func didSelectItem() {
        collectionView.rx.itemSelected
            .subscribe(with: self, onNext: { (self, indexPath) in
                let selectedMovie = self.searchDataSource.snapshot().itemIdentifiers[indexPath.row]
                self.coordinator?.showDetailViewController(at: self, of: selectedMovie.movieId)
            }).disposed(by: disposeBag)
    }
    
    private func contentOffset() -> Observable<Bool> {
        return collectionView.rx.contentOffset
            .withUnretained(self)
            .filter { (self, offset) in
                guard self.collectionView.contentSize.height != 0 else {
                    return false
                }
                return self.collectionView.frame.height + offset.y + 100 >= self.collectionView.contentSize.height
            }
            .map { offset -> Bool in
                return true
            }
    }
}
