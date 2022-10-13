//
//  MyAccountViewController.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/19.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit

protocol MyAccountViewControllerDelegate: AnyObject {
    func showDetailViewController(at viewController: UIViewController, of id: Int)
}

final class MyAccountViewController: UIViewController, StoryboardView {
    private enum Section {
        case main
    }
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: createCollectionViewLayout())
        return collectionView
    }()
    
    private let ratedMovieRelay = PublishRelay<RatedMovie>()
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, MovieListItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, MovieListItem>
    private var searchDataSource: DataSource!
    var disposeBag = DisposeBag()
    weak var coordinator: MyAccountViewControllerDelegate?
    
    init(reactor: MyAccountReactor) {
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
        view.addSubview(collectionView)
        view.backgroundColor = .white
        configureDataSource()
        configureLayout()
//        didSelectItem()
    }
    
    func bind(reactor: MyAccountReactor) {
        bindAction(reactor)
        bindState(reactor)
    }
    
    private func bindAction(_ reactor: MyAccountReactor) {
        rx.viewWillAppear.asObservable()
            .map { Reactor.Action.setInitialData }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        ratedMovieRelay.asObservable()
            .map { Reactor.Action.rate($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(_ reactor: MyAccountReactor) {
        reactor.state
            .map { $0.movies }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: [])
            .drive(with: self, onNext: { (self, result) in
                self.applySearchResultSnapshot(result: result)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$ratedMovie)
            .asDriver(onErrorJustReturn: RatedMovie(movieId: 0, rating: 0))
            .drive(with: self, onNext: { (self, ratedMovie) in
                guard let ratedMovie = ratedMovie else {
                    return
                }
                self.presentRatedAlert(with: ratedMovie.rating)
            })
            .disposed(by: disposeBag)
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
    
    private func createCollectionViewLayout() -> UICollectionViewFlowLayout {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(
            width: view.frame.width - CGFloat(30),
            height: 110
        )
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 1.0
        return layout
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
