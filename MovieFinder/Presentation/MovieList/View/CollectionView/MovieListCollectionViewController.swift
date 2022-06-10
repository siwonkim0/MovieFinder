//
//  MovieListByTopicViewController.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/31.
//

import UIKit

class MovieListCollectionViewController: UIViewController, UICollectionViewDelegate {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private enum MovieListSection {
        case main
    }
    
    let viewModel: MovieListCollectionViewModel
    private var movieListDataSource: UICollectionViewDiffableDataSource<MovieListSection, MovieListCollectionViewItemViewModel>!
    
    init(viewModel: MovieListCollectionViewModel, nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.viewModel = viewModel
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCollectionViewCell()
        titleLabel.text = viewModel.collectionType.title
        titleLabel.textColor = .black
        setLayout()
        Task {
            await reloadCollectionView()
        }
        configureDataSource()
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
        snapshot.appendSections([.main])
        snapshot.appendItems(movies)
        movieListDataSource?.apply(snapshot)
    }
    
    func reloadCollectionView() async {
        await viewModel.getMovieListItem()
        populate(with: self.viewModel.itemViewModels)
    }
    
    func registerCollectionViewCell() {
        self.collectionView.register(UINib(nibName: "MovieListCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MovieListCollectionViewCell")
        self.collectionView.delegate = self
        self.collectionView.backgroundColor = .blue
    }
    
    func setLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 400, height: 400)

        collectionView?.setCollectionViewLayout(layout, animated: false)
    }


}
