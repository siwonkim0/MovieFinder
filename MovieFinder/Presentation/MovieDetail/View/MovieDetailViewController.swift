//
//  MovieDetailViewController.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/19.
//

import UIKit
import RxSwift
import RxRelay
import Kingfisher
import Cosmos
import SnapKit
import ReactorKit

final class MovieDetailViewController: UIViewController, StoryboardView {
    private enum DetailSection: Hashable, CaseIterable {
        case basicInfo
        case review
        
        var description: String {
            switch self {
            case .basicInfo:
                return ""
            case .review:
                return "Comments"
            }
        }
    }
    
    private enum DetailItem: Hashable {
        case basicInfo(BasicInfoCellViewModel.ID)
        case review(MovieDetailReview.ID)
    }
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: createCollectionViewLayout())
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    private let plotTitleLabel: UILabel = {
        let plotTitleLabel = UILabel()
        plotTitleLabel.text = "Plot Summary"
        plotTitleLabel.textColor = .black
        plotTitleLabel.font = UIFont(name: "AvenirNext-Bold", size: 20) ?? UIFont.systemFont(ofSize: 20)
        return plotTitleLabel
    }()
    
    private let plotLabel: UILabel = {
        let plotLabel = UILabel()
        plotLabel.numberOfLines = 0
        plotLabel.textColor = .black
        plotLabel.font = UIFont(name: "AvenirNext-Regular", size: 15) ?? UIFont.systemFont(ofSize: 15)
        return plotLabel
    }()

    private let ratingRelay = PublishRelay<RatedMovie>()
    private typealias DataSource = UICollectionViewDiffableDataSource<DetailSection, DetailItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<DetailSection, DetailItem>
    private var movieDetailDataSource: DataSource!
    private var snapshot = Snapshot()
    var disposeBag = DisposeBag()
    
    init(reactor: MovieDetailReactor) {
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
        configureCollectionView()
        configureDataSource()
    }
    
    func bind(reactor: MovieDetailReactor) {
        bindAction(reactor)
        bindState(reactor)
    }
    
    private func bindAction(_ reactor: MovieDetailReactor) {
        rx.viewWillAppear.asObservable()
            .map { Reactor.Action.setInitialData }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        ratingRelay.asObservable()
            .map { Reactor.Action.rate($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .withUnretained(self)
            .map { (self, indexPath) -> MovieDetailReview.ID? in
                guard let item = self.movieDetailDataSource.itemIdentifier(for: indexPath) else {
                    return nil
                }
                if case let .review(selectedReview) = item {
                    return selectedReview
                }
                return nil
            }
            .map { Reactor.Action.setReviewState($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(_ reactor: MovieDetailReactor) {
        reactor.state
            .compactMap { $0.basicInfos }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: BasicInfoCellViewModel(
                movie: MovieDetailBasicInfo(
                    id: 0,
                    imdbID: "N/A",
                    rating: 0,
                    posterPath: "N/A",
                    title: "N/A",
                    genre: "N/A",
                    year: "N/A",
                    runtime: "N/A",
                    plot: "N/A",
                    actors: "N/A"
                ), myRating: 0))
            .drive(with: self, onNext: { (self, basicInfo) in
                self.applyBasicInfoSnapshot(info: basicInfo)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.reviews }
            .distinctUntilChanged()
            .filter { _ in reactor.currentState.selectedReviewID == nil } //ReviewID가 없는 경우에만 이벤트 받도록
            .asDriver(onErrorJustReturn: [])
            .drive(with: self, onNext: { (self, reviews) in
                self.applyReviewsSnapshot(reviews: reviews)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$rating)
            .asDriver(onErrorJustReturn: 0)
            .drive(with: self, onNext: { (self, rating) in
                guard let rating = rating else {
                    return
                }
                self.presentRatedAlert(with: rating)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$selectedReviewID) //@Pulse: 같은 ID값이 set되어도 이벤트 발생
            .asDriver(onErrorJustReturn: UUID())
            .drive(with: self, onNext: { (self, reviewID) in
                guard let reviewID = reviewID else {
                    return
                }
                let items = DetailItem.review(reviewID)
                self.snapshot.reconfigureItems([items])
                self.movieDetailDataSource.apply(self.snapshot, animatingDifferences: false)
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: - CollectionView DataSource
    private func configureDataSource() {
        movieDetailDataSource = DataSource(collectionView: self.collectionView) { [weak self] collectionView, indexPath, itemIdentifier in
            
            switch itemIdentifier {
            case .basicInfo(_):
                let cell = collectionView.dequeueReusableCell(withClass: BasicInfoCollectionViewCell.self, indexPath: indexPath)
                guard let basicInfo = self?.reactor?.currentState.basicInfos else {
                    return BasicInfoCollectionViewCell()
                }
                cell.delegate = self
                cell.configure(with: basicInfo)
                return cell
            case .review(let id):
                let cell = collectionView.dequeueReusableCell(withClass: MovieDetailReviewsCollectionViewCell.self, indexPath: indexPath)
                guard let reviews = self?.reactor?.currentState.reviews,
                      let review = reviews.filter({ $0.id == id }).first else {
                    return MovieDetailReviewsCollectionViewCell()
                }
                cell.configure(with: review)
                return cell
            }
        }
        
        self.movieDetailDataSource.supplementaryViewProvider = { [weak self] (collectionView, kind, indexPath) in
            let header = collectionView.dequeueReuseableSupplementaryView(withClass: MovieDetailHeaderView.self, indexPath: indexPath)
            let section = self?.movieDetailDataSource.snapshot().sectionIdentifiers[indexPath.section]
            header.label.text = section?.description
            return header
        }
    }
    
    private func applyBasicInfoSnapshot(info: BasicInfoCellViewModel) {
        let infoID = info.id
        let items = [DetailItem.basicInfo(infoID)]
        snapshot.appendItems(items, toSection: DetailSection.basicInfo)
        self.movieDetailDataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    private func applyReviewsSnapshot(reviews: [MovieDetailReview]) {
        let reviewsID = reviews.map { $0.id }
        let items = reviewsID.map { DetailItem.review($0) }
        snapshot.appendItems(items, toSection: DetailSection.review)
        self.movieDetailDataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    //MARK: - Configure View
    private func setView() {
        view.backgroundColor = .white
        navigationItem.largeTitleDisplayMode = .never
    }
    
    private func configureCollectionView() {
        snapshot.appendSections(DetailSection.allCases)
        registerCollectionViewCell()
    }
    
    private func registerCollectionViewCell() {
        collectionView.registerCell(withClass: BasicInfoCollectionViewCell.self)
        collectionView.registerCell(withNib: MovieDetailReviewsCollectionViewCell.self)
        collectionView.registerCell(withNib: PlotSummaryCollectionViewCell.self)
        collectionView.registerSupplementaryView(withClass: MovieDetailHeaderView.self)
    }
    
    private func configureLayout() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(5)
        }
    }
    
    private func createCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnvironment in
            guard let self = self else {
                return nil
            }
            let section = DetailSection.allCases[sectionIndex]
            switch section {
            case .basicInfo:
                let item = NSCollectionLayoutItem(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(650))
                )
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(650)
                    ),
                    subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 20
                section.boundarySupplementaryItems = [self.supplementaryHeaderItem()]
                section.contentInsets = .init(top: 0, leading: 10, bottom: 0, trailing: 10)
                return section
                
            case .review:
                let item = NSCollectionLayoutItem(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(488))
                )
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(488)
                    ),
                    subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 20
                section.boundarySupplementaryItems = [self.supplementaryHeaderItem()]
                section.contentInsets = .init(top: 0, leading: 10, bottom: 0, trailing: 10)
                return section
            }
        }
    }
    
    private func supplementaryHeaderItem() -> NSCollectionLayoutBoundarySupplementaryItem {
        NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(44)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)
    }

}

//MARK: - Delegate
extension MovieDetailViewController: BasicInfoCellDelegate {
    func didTapRatingViewInCell(_ movie: RatedMovie) {
        ratingRelay.accept(movie)
    }
    
    private func presentRatedAlert(with rating: Double) {
        let alert = UIAlertController(title: "Successfully Rated", message: "\(rating)", preferredStyle: .alert)
        let confirm = UIAlertAction(title: "Okay", style: .default)
        alert.addAction(confirm)
        present(alert, animated: true)
    }
}
