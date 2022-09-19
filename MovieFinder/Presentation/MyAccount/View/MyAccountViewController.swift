//
//  MyAccountViewController.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/19.
//

import UIKit
import RxSwift
import RxCocoa

protocol MyAccountViewControllerDelegate {
    func showDetailViewController(at viewController: UIViewController, of id: Int)
}

final class MyAccountViewController: UIViewController {
    private enum Section {
        case main
    }
    
    var coordinator: MyAccountViewControllerDelegate?
    private let ratedMovieRelay = PublishRelay<RatedMovie>()
    private let viewModel: MyAccountViewModel
    private let disposeBag = DisposeBag()
    private var searchDataSource: DataSource!
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, MovieListItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, MovieListItem>
    
    private lazy var collectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(
            width: view.frame.width - CGFloat(30),
            height: 110
        )
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 1.0
        
        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        return collectionView
    }()
    
    init(viewModel: MyAccountViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        view.backgroundColor = .white
        configureBind()
        configureDataSource()
        configureLayout()
//        didSelectItem()
    }
    
    //MARK: - Data Binding
    private func configureBind() {
        let input = MyAccountViewModel.Input(
            viewWillAppear: rx.viewWillAppear.asObservable(),
            tapRatingButton: ratedMovieRelay.asObservable()
        )
        
        let output = viewModel.transform(input)
        output.ratingList
            .drive(with: self, onNext: { (self, result) in
                self.applySearchResultSnapshot(result: result)
            })
            .disposed(by: disposeBag)
        output.ratingDone
            .emit(with: self, onNext: { (self, ratedMovie) in
                self.presentRatedAlert(with: ratedMovie.rating)
            }).disposed(by: disposeBag)
        
    }
    
    //MARK: - CollectionView DataSource
    private func configureDataSource() {
        collectionView.registerCell(withNib: AccountCollectionViewCell.self)
        searchDataSource = DataSource(collectionView: self.collectionView) { collectionView, indexPath, model in
            let cell = collectionView.dequeueReusableCell(
                withClass: AccountCollectionViewCell.self,
                indexPath: indexPath
            )
            cell.delegate = self
            cell.configure(with: model)
            return cell
        }
    }
    
    private func applySearchResultSnapshot(result: [MovieListItem]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(result, toSection: .main)
        searchDataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    private func didSelectItem() {
        collectionView.rx.itemSelected
            .subscribe(with: self, onNext: { (self, indexPath) in
                let selectedMovie = self.searchDataSource.snapshot().itemIdentifiers[indexPath.row]
                self.coordinator?.showDetailViewController(at: self, of: selectedMovie.id)
            }).disposed(by: disposeBag)
    }
    
    //MARK: - Configure View
    private func configureLayout() {
        collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.bottom.leading.trailing.equalToSuperview()
        }
    }
}

//MARK: - Delegate
extension MyAccountViewController: AccountCellDelegate {
    func didTapRatingViewInCell(_ movie: RatedMovie) {
        ratedMovieRelay.accept(movie)
    }
    
    private func presentRatedAlert(with rating: Double) {
        let alert = UIAlertController(title: "Successfully Rated", message: "\(rating)", preferredStyle: .alert)
        let confirm = UIAlertAction(title: "Okay", style: .default)
        alert.addAction(confirm)
        present(alert, animated: true)
    }
    
}
