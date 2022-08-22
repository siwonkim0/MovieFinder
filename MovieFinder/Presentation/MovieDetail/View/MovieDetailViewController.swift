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

final class MovieDetailViewController: UIViewController {
    private enum MovieDetailItem: Hashable {
        case plotSummary(MovieDetailBasicInfo)
        case review(MovieDetailReview)
    }

    private enum DetailSection: Hashable, CaseIterable {
        case plotSummary
        case review
        
        var description: String {
            switch self {
            case .plotSummary:
                return "Plot Summary"
            case .review:
                return "Comments"
            }
        }
    }
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: createCollectionViewLayout())
        collectionView.registerCell(withNib: MovieDetailReviewsCollectionViewCell.self)
        collectionView.registerCell(withNib: PlotSummaryCollectionViewCell.self)
        collectionView.registerSupplementaryView(withClass: MovieDetailHeaderView.self)
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .black
        return collectionView
    }()
    
    let posterImageView: UIImageView = {
        let posterImageView = UIImageView()
        posterImageView.layer.cornerRadius = 10
        posterImageView.layer.masksToBounds = true
        return posterImageView
    }()
    
    let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textColor = .white
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        titleLabel.adjustsFontSizeToFitWidth = true
        return titleLabel
    }()
    
    let releaseYearLabel: UILabel = {
        let releaseYearLabel = UILabel()
        releaseYearLabel.textColor = .white
        releaseYearLabel.font = UIFont.preferredFont(forTextStyle: .callout)
        releaseYearLabel.adjustsFontSizeToFitWidth = true
        return releaseYearLabel
    }()
    
    let genreLabel: UILabel = {
        let genreLabel = UILabel()
        genreLabel.textColor = .white
        genreLabel.font = UIFont.preferredFont(forTextStyle: .callout)
        genreLabel.adjustsFontSizeToFitWidth = true
        return genreLabel
    }()
    
    let runtimeLabel: UILabel = {
        let runtimeLabel = UILabel()
        runtimeLabel.textColor = .white
        runtimeLabel.font = UIFont.preferredFont(forTextStyle: .callout)
        runtimeLabel.adjustsFontSizeToFitWidth = true
        return runtimeLabel
    }()
    
    let averageRatingLabel: UILabel = {
        let averageRatingLabel = UILabel()
        averageRatingLabel.textColor = .white
        averageRatingLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        averageRatingLabel.adjustsFontSizeToFitWidth = true
        return averageRatingLabel
    }()
    
    let ratingView: CosmosView = {
        let ratingView = CosmosView()
        ratingView.rating = 0
        return ratingView
    }()
    
    let scrollView = UIScrollView()
    let contentView = UIView()
    
    private let ratingRelay = BehaviorRelay<Double>(value: 0)
    private lazy var input = MovieDetailViewModel.Input(viewWillAppear: self.rx.viewWillAppear.asObservable(), tapRatingButton: ratingRelay.asObservable())
    
    private let viewModel: MovieDetailViewModel
    private let disposeBag = DisposeBag()
    private var movieDetailDataSource: DataSource!
    private var snapshot = Snapshot()
    
    private typealias DataSource = UICollectionViewDiffableDataSource<DetailSection, MovieDetailReview.ID>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<DetailSection, MovieDetailReview.ID>
    
    init(viewModel: MovieDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    init?(viewModel: MovieDetailViewModel, coder: NSCoder) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        configureCollectionView()
        configureDataSource()
        configureBind()
        didSelectItem()
        configureLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.collectionView.snp.updateConstraints { make in
            make.height.equalTo(self.collectionView.contentSize.height)
        }
        collectionView.layoutIfNeeded()
    }
    
    override func viewWillLayoutSubviews() {
       super.viewWillLayoutSubviews()
       self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    private func setView() {
        self.view.backgroundColor = .black
        navigationItem.largeTitleDisplayMode = .never
    }
    
    private func configureCollectionView() {
        snapshot.appendSections(DetailSection.allCases)
    }
    
    private func configureDataSource() {
        self.movieDetailDataSource = DataSource(collectionView: self.collectionView) { [weak self] collectionView, indexPath, itemIdentifier in
            self?.viewModel.updateReviewState(with: itemIdentifier)
            let cell = collectionView.dequeueReusableCell(withClass: MovieDetailReviewsCollectionViewCell.self, indexPath: indexPath)
            guard let reviews = self?.viewModel.reviews,
                  let review = reviews.filter({ $0.id == itemIdentifier }).first else {
                return MovieDetailReviewsCollectionViewCell()
            }
            cell.configure(with: review)

            return cell
        }
        
        self.movieDetailDataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) in
            let header = collectionView.dequeueReuseableSupplementaryView(withClass: MovieDetailHeaderView.self, indexPath: indexPath)
            let section = self.movieDetailDataSource.snapshot().sectionIdentifiers[indexPath.section]
            header.label.text = section.description
            return header
        }
    }
    
//    private func applyPlotSummarySnapshot(with basicInfo: MovieDetailBasicInfo) {
//        let basicInfo = MovieDetailItem.plotSummary(basicInfo)
//        snapshot.appendItems([basicInfo], toSection: DetailSection.plotSummary)
//        self.movieDetailDataSource?.apply(snapshot)
//    }
    
    private func applyReviewsSnapshot(reviews: [MovieDetailReview]) {
        let reviewsID = reviews.map { $0.id }
        snapshot.appendItems(reviewsID, toSection: DetailSection.review)
        self.movieDetailDataSource?.apply(snapshot)
    }
    
    private func configureBind() {
        ratingView.didFinishTouchingCosmos = { [weak self] rating in
            self?.ratingRelay.accept(rating)
            self?.ratingView.rating = rating
        }
        
        let output = viewModel.transform(input)
        output.reviewsObservable
            .observe(on: MainScheduler.instance)
            .take(1)
            .subscribe(with: self, onNext: { (self, reviews) in
                self.applyReviewsSnapshot(reviews: reviews)
                self.collectionView.snp.updateConstraints { make in
                    make.height.equalTo(self.collectionView.contentSize.height)
                }
            }).disposed(by: disposeBag)
        output.basicInfoObservable
            .observe(on: MainScheduler.instance)
            .take(1)
            .subscribe(with: self, onNext: { (self, basicInfo) in
                self.configure(basicInfo)
            }).disposed(by: disposeBag)
        output.ratingDriver
            .map { $0 ? self.ratingView.rating : 0}
            .drive(ratingView.rx.rating)
            .disposed(by: disposeBag)
        output.ratingObservable
            .asDriver(onErrorJustReturn: 0)
            .drive(ratingView.rx.rating)
            .disposed(by: disposeBag)
    }
    
    private func configure(_ basicInfo: MovieDetailBasicInfo) {
        guard let posterPath = basicInfo.posterPath,
              let url = ImageRequest(urlPath: "\(posterPath)").urlComponents else {
            return
        }
        self.configureImageView(with: url)
        self.titleLabel.text = basicInfo.title
        self.releaseYearLabel.text = basicInfo.year
        self.genreLabel.text = basicInfo.genre
        self.runtimeLabel.text = basicInfo.runtime
        self.averageRatingLabel.text = "⭐" + String(basicInfo.rating * 0.5)
//        self.applyPlotSummarySnapshot(with: basicInfo)
    }
    
    private func configureImageView(with url: URL) {
        self.posterImageView.layer.cornerRadius = 20
        self.posterImageView.kf.indicatorType = .activity
        self.posterImageView.kf.setImage(with: url,
                                         placeholder: UIImage(),
                                         options: [.transition(.fade(1)),
                                            KingfisherOptionsInfoItem.forceTransition],
                                         completionHandler: nil)
    }
    
    func didSelectItem() {
        collectionView.rx.itemSelected
            .subscribe(with: self, onNext: { (self, indexPath) in
                guard let movieDetailItem = self.movieDetailDataSource.itemIdentifier(for: indexPath) else {
                    return
                }
                self.viewModel.toggle(with: movieDetailItem)
                self.viewModel.updateReviewState(with: movieDetailItem)
                self.snapshot.reconfigureItems([movieDetailItem])
                self.movieDetailDataSource.apply(self.snapshot, animatingDifferences: false)
                
                self.collectionView.snp.updateConstraints { make in
                    make.height.equalTo(self.collectionView.contentSize.height)
                }
            }).disposed(by: disposeBag)
    }
    
    private func createCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnvironment in
            guard let self = self else {
                return nil
            }
            let section = DetailSection.allCases[sectionIndex]
            switch section {
            case .plotSummary:
                let item = NSCollectionLayoutItem(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(488)))
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(488)),
                    subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [self.supplementaryHeaderItem()]
                section.contentInsets = .init(top: 0, leading: 10, bottom: 0, trailing: 10)
                return section
            case .review:
                let item = NSCollectionLayoutItem(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(488)))
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(488)),
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
    
    func configureLayout() {
        let releaseDateStackView = UIStackView(arrangedSubviews: [releaseYearLabel, genreLabel, runtimeLabel])
        let descriptionStackView = UIStackView(arrangedSubviews: [titleLabel, releaseDateStackView, averageRatingLabel, ratingView])
        let entireStackView = UIStackView(arrangedSubviews: [posterImageView, descriptionStackView, collectionView])
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(entireStackView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView.setContentHuggingPriority(.init(rawValue: 250), for: .vertical)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        entireStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }
        entireStackView.axis = .vertical
        entireStackView.alignment = .center
        entireStackView.distribution = .fill
        entireStackView.spacing = 10

        posterImageView.setContentHuggingPriority(.init(rawValue: 200), for: .vertical)
        posterImageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(400)
        }
        
        descriptionStackView.axis = .vertical
        descriptionStackView.alignment = .center
        descriptionStackView.distribution = .equalSpacing
        descriptionStackView.spacing = 10
        
        releaseDateStackView.axis = .horizontal
        releaseDateStackView.distribution = .equalSpacing
        releaseDateStackView.spacing = 5
        
        collectionView.snp.makeConstraints { make in
            make.height.equalTo(10)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
}
