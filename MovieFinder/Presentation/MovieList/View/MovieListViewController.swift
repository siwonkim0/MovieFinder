//
//  MovieListViewController.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/19.
//

import UIKit
import RxSwift

protocol MovieListViewControllerDelegate {
    func showDetailViewController(at viewController: UIViewController, of id: Int)
}

final class MovieListViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var coordinator: MovieListViewControllerDelegate?
    private let viewModel: MovieListViewModel
    private let refreshControl = UIRefreshControl()
    private let refresh = PublishSubject<Void>()
    private let disposeBag = DisposeBag()
    private var movieListDataSource: DataSource!
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, MovieListItemViewModel>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, MovieListItemViewModel>
    
    init?(viewModel: MovieListViewModel, coder: NSCoder) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCollectionViewItems()
        configureDataSource()
        configureBind()
        collectionView.setCollectionViewLayout(createLayout(), animated: true)
        self.collectionView.backgroundColor = .black
        didSelectedItem()
    }

    private func registerCollectionViewItems() {
        self.collectionView.refreshControl = refreshControl
        self.refreshControl.tintColor = .white

        self.collectionView.register(
            UINib(nibName: "MovieListCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "MovieListCollectionViewCell")
        self.collectionView.register(
            MovieListHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "MovieListHeaderView")
    }
    
    private func configureDataSource() {
        self.movieListDataSource = DataSource(collectionView: self.collectionView) { collectionView, indexPath, itemIdentifier in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "MovieListCollectionViewCell",
                for: indexPath) as? MovieListCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: itemIdentifier)
            return cell
        }
        
        self.movieListDataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) in
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: "MovieListHeaderView",
                for: indexPath) as? MovieListHeaderView else {
                return MovieListHeaderView()
            }
            
            let section = self.movieListDataSource.snapshot().sectionIdentifiers[indexPath.section]
            header.label.text = section.title

            return header
        }
    }
    
    private func applySnapshot(with sections: [Section]) {
        var snapshot = Snapshot()
        snapshot.appendSections(sections)
        sections.forEach { section in
            snapshot.appendItems(section.movies, toSection: section)
        }
        self.movieListDataSource?.apply(snapshot)
    }
    
    private func configureBind() {
        refreshControl.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { aa in
                self.refresh.onNext(aa)
            }).disposed(by: disposeBag)
        let input = MovieListViewModel.Input(viewWillAppear: self.rx.viewWillAppear.asObservable(), refresh: refresh.asObservable())
        let output = viewModel.transform(input)
        
        output.sectionObservable
            .observe(on: MainScheduler.instance)
            .take(1)
            .withUnretained(self)
            .subscribe(onNext: { (self, sections) in
                self.applySnapshot(with: sections)
            }).disposed(by: disposeBag)
        
        output.refresh
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { (self, sections) in
                self.applySnapshot(with: sections)
                self.refreshControl.endRefreshing()
            }).disposed(by: disposeBag)
    }
    
    func didSelectedItem() {
        collectionView.rx.itemSelected
            .withUnretained(self)
            .subscribe(onNext: { (self, indexPath) in
                let selectedSection = self.movieListDataSource.snapshot().sectionIdentifiers[indexPath.section]
                let selectedMovie = selectedSection.movies[indexPath.row]
                self.coordinator?.showDetailViewController(at: self, of: selectedMovie.id)
            }).disposed(by: disposeBag)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(
            top: 20,
            leading: 20,
            bottom: 20,
            trailing: 20)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(1.0))
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .paging
        section.interGroupSpacing = 0
        
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

