//
//  MovieListViewController.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/19.
//

import UIKit
import RxSwift

final class MovieListViewController: UIViewController, UICollectionViewDelegate {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let viewModel: MovieListViewModel
    private let disposeBag = DisposeBag()
    private var movieListDataSource: DataSource!
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, MovieListItemViewModel>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, MovieListItemViewModel>
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCollectionViewItems()
        configureDataSource()
        configureBind()
        collectionView.setCollectionViewLayout(createLayout(), animated: true)
        self.collectionView.backgroundColor = .black
    }
    
    init?(viewModel: MovieListViewModel, coder: NSCoder) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func registerCollectionViewItems() {
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
    
    private func populate(with sections: [Section]) {
        var snapshot = Snapshot()
        snapshot.appendSections(sections)
        sections.forEach { section in
            snapshot.appendItems(section.movies, toSection: section)
        }
        self.movieListDataSource?.apply(snapshot)
    }
    
    private func configureBind() {
        let input = MovieListViewModel.Input(viewWillAppear: self.rx.viewWillAppear.asObservable())
        let output = viewModel.transform(input)
        
        output.sectionObservable
            .withUnretained(self)
            .subscribe(onNext: { (self, sections) in
                self.populate(with: sections)
                print("성공")
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
