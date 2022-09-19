//
//  MovieListViewController.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/19.
//

import UIKit
import RxSwift
import SnapKit

protocol MovieListViewControllerDelegate {
    func showDetailViewController(at viewController: UIViewController, of id: Int)
}

final class MovieListViewController: UIViewController {
    var coordinator: MovieListViewControllerDelegate?
    private var collectionView: UICollectionView?
    private let viewModel: MovieListViewModel
    private let refreshControl = UIRefreshControl()
    private let refresh = PublishSubject<Void>()
    private let disposeBag = DisposeBag()
    private var movieListDataSource: DataSource!
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, MovieListCellViewModel>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, MovieListCellViewModel>
    
    init(viewModel: MovieListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        setCollectionView()
        configureDataSource()
        configureBind()
        didSelectItem()
    }
    
    //MARK: - Data Binding
    private func configureBind() {
        refreshControl.rx.controlEvent(.valueChanged)
            .subscribe(with: self, onNext: { (self, event) in
                self.refresh.onNext(event)
            }).disposed(by: disposeBag)
        let input = MovieListViewModel.Input(viewWillAppear: rx.viewWillAppear.asObservable(), refresh: refresh.asObservable())
        let output = viewModel.transform(input)
        
        output.section
            .drive(with: self, onNext: { (self, sections) in
                self.applySnapshot(with: sections)
            }).disposed(by: disposeBag)
        
        output.refresh
            .emit(with: self, onNext: { (self, sections) in
                self.applySnapshot(with: sections)
                self.refreshControl.endRefreshing()
            }).disposed(by: disposeBag)
    }
    
    private func didSelectItem() {
        collectionView?.rx.itemSelected
            .subscribe(with: self, onNext: { (self, indexPath) in
                let selectedSection = self.movieListDataSource.snapshot().sectionIdentifiers[indexPath.section]
                let selectedMovie = selectedSection.movies[indexPath.row]
                self.coordinator?.showDetailViewController(at: self, of: selectedMovie.id)
            }).disposed(by: disposeBag)
    }
    
    //MARK: - CollectionView DataSource
    private func configureDataSource() {
        guard let collectionView = collectionView else {
            return
        }

        movieListDataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withClass: MovieListCollectionViewCell.self, indexPath: indexPath)
            cell.configure(with: itemIdentifier)
            return cell
        }
        
        movieListDataSource.supplementaryViewProvider = { [weak self] (collectionView, kind, indexPath) in
            let header = collectionView.dequeueReuseableSupplementaryView(withClass: MovieListHeaderView.self, indexPath: indexPath)
            
            let section = self?.movieListDataSource.snapshot().sectionIdentifiers[indexPath.section]
            header.label.text = section?.title

            return header
        }
    }
    
    private func applySnapshot(with sections: [Section]) {
        var snapshot = Snapshot()
        snapshot.appendSections(sections)
        sections.forEach { section in
            snapshot.appendItems(section.movies, toSection: section)
        }
        movieListDataSource?.apply(snapshot)
    }
    
    //MARK: - Configure View
    private func setView() {
        view.backgroundColor = .white
        edgesForExtendedLayout = []
    }

    private func setCollectionView() {
        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: createLayout())
        guard let collectionView = collectionView else {
            return
        }
        view.addSubview(collectionView)
        collectionView.backgroundColor = .white
        collectionView.refreshControl = refreshControl
        refreshControl.tintColor = .black
        collectionView.registerCell(withNib: MovieListCollectionViewCell.self)
        collectionView.registerSupplementaryView(withClass: MovieListHeaderView.self)
        
        collectionView.snp.makeConstraints({ make in
            make.trailing.bottom.top.equalToSuperview()
            make.leading.equalToSuperview().inset(10)
        })
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(
            top: 10,
            leading: 0,
            bottom: 10,
            trailing: 0)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .fractionalWidth(1.0))
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 10
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)
        section.boundarySupplementaryItems = [sectionHeader]
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }

}

