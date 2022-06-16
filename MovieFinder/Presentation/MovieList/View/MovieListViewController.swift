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
    
    let disposeBag = DisposeBag()
    let viewModel: MovieListViewModel
    
    private enum MovieListSection {
        case nowPlaying
        case popular
//        case topRated
//        case upcoming
    }
    
    private var movieListDataSource: UICollectionViewDiffableDataSource<MovieListSection, MovieListCollectionViewItemViewModel>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCollectionViewCell()
        configureDataSource()
        configureBind()
        collectionView.setCollectionViewLayout(createLayout(), animated: true)
    }
    
    init?(viewModel: MovieListViewModel, coder: NSCoder) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createLayout() -> UICollectionViewLayout {
        //item 화면에 꽉차게, group당 item 1개
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
        //특정 섹션만 가로 스크롤되도록
        section.orthogonalScrollingBehavior = .paging
        section.interGroupSpacing = 0
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    private func registerCollectionViewCell() {
        self.collectionView.register(UINib(nibName: "MovieListCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MovieListCollectionViewCell")
        self.collectionView.delegate = self
        self.collectionView.backgroundColor = .black
    }
    
    private func configureDataSource() {
        self.movieListDataSource = UICollectionViewDiffableDataSource<MovieListSection, MovieListCollectionViewItemViewModel>(collectionView: self.collectionView) { collectionView, indexPath, itemIdentifier in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieListCollectionViewCell", for: indexPath) as? MovieListCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: itemIdentifier)
            return cell
        }
    }
    
    private func populate(with movies: [MovieListCollectionViewItemViewModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<MovieListSection, MovieListCollectionViewItemViewModel>()
        snapshot.appendSections([.nowPlaying])
        snapshot.appendItems(movies)
        
        movieListDataSource?.apply(snapshot)
    }
    
    private func configureBind() {
        let input = MovieListViewModel.Input(viewWillAppear: self.rx.viewWillAppear.asObservable())
        let output = viewModel.transform(input)
        output.movieItems
            .withUnretained(self)
            .subscribe(onNext: { (self, movieItems) in
                self.populate(with: movieItems)
                print("성공")
            }).disposed(by: disposeBag)
    }

}
