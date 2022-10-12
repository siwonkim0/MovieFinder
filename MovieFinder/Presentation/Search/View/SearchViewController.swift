//
//  SearchViewController.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/19.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit

protocol SearchViewControllerDelegate {
    func showDetailViewController(at viewController: UIViewController, of id: Int)
}

final class SearchViewController: UIViewController, StoryboardView {
    private enum Section {
        case main
    }
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, SearchCellViewModel>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, SearchCellViewModel>
    private var searchDataSource: DataSource!
    var disposeBag = DisposeBag()
    var coordinator: SearchViewControllerDelegate?
    
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
    
    init(reactor: SearchViewReactor) {
        super.init(nibName: nil, bundle: nil)
        defer {
            self.reactor = reactor
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        configureLayout()
        configureDataSource()
        didSelectItem()
    }
    
    func bind(reactor: SearchViewReactor) {
        bindAction(reactor)
        bindState(reactor)
    }
    
    private func bindAction(_ reactor: SearchViewReactor) {
        searchController.searchBar.rx.text.orEmpty
            .filter { $0.count > 0 }
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .map { Reactor.Action.searchKeyword($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        collectionView.rx.contentOffset
            .skip(3)
            .withUnretained(self)
            .filter { (self, offset) in
                guard self.collectionView.contentSize.height > 0 else {
                    return false
                }
                return self.collectionView.frame.height + offset.y >= self.collectionView.contentSize.height
            }
            .map { _ in Reactor.Action.loadNextPage }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        searchController.searchBar.rx.cancelButtonClicked
            .map { Reactor.Action.clearSearchKeyword }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(_ reactor: SearchViewReactor) {
        reactor.state
            .map { $0.movieResults }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {
                self.applySearchResultSnapshot(result: $0)
            })
            .disposed(by: disposeBag)
    }
    
    private func didSelectItem() {
        collectionView.rx.itemSelected
            .subscribe(with: self, onNext: { (self, indexPath) in
                let selectedMovie = self.searchDataSource.snapshot().itemIdentifiers[indexPath.row]
                self.coordinator?.showDetailViewController(at: self, of: selectedMovie.movieId)
            }).disposed(by: disposeBag)
    }
    
    //MARK: - CollectionView DataSource
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
    
    private func applySearchResultSnapshot(result: [SearchCellViewModel]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(result, toSection: .main)
        searchDataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    //MARK: - Configure View
    private func setView() {
        navigationItem.searchController = searchController
        view.addSubview(collectionView)
    }
    
    private func configureLayout() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
