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
    private enum DetailSection: Hashable, CaseIterable {
        case review
        
        var description: String {
            switch self {
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
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    let posterImageView: UIImageView = {
        let posterImageView = UIImageView()
        posterImageView.layer.cornerRadius = 10
        posterImageView.layer.masksToBounds = true
        posterImageView.layer.cornerRadius = 20
        posterImageView.kf.indicatorType = .activity
        return posterImageView
    }()
    
    let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textColor = .black
        titleLabel.font = UIFont(name: "AvenirNext-Bold", size: 30) ?? UIFont.systemFont(ofSize: 30)
        titleLabel.adjustsFontSizeToFitWidth = true
        return titleLabel
    }()
    
    let descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.textColor = .black
        descriptionLabel.font = UIFont(name: "AvenirNext-Regular", size: 15) ?? UIFont.systemFont(ofSize: 15)
        descriptionLabel.adjustsFontSizeToFitWidth = true
        return descriptionLabel
    }()
    
    let averageRatingLabel: UILabel = {
        let averageRatingLabel = UILabel()
        averageRatingLabel.textColor = .black
        averageRatingLabel.font = UIFont(name: "AvenirNext-Regular", size: 15) ?? UIFont.systemFont(ofSize: 15)
        averageRatingLabel.adjustsFontSizeToFitWidth = true
        return averageRatingLabel
    }()
    
    let ratingView: CosmosView = {
        let ratingView = CosmosView()
        ratingView.rating = 0
        ratingView.settings.fillMode = .half
        ratingView.settings.filledColor = .systemYellow
        ratingView.settings.emptyColor = .lightGray
        ratingView.settings.emptyBorderColor = .lightGray
        ratingView.settings.starSize = 30
        return ratingView
    }()
    
    let plotTitleLabel: UILabel = {
        let plotTitleLabel = UILabel()
        plotTitleLabel.text = "Plot Summary"
        plotTitleLabel.textColor = .black
        plotTitleLabel.font = UIFont(name: "AvenirNext-Bold", size: 20) ?? UIFont.systemFont(ofSize: 20)
        return plotTitleLabel
    }()
    
    let plotLabel: UILabel = {
        let plotLabel = UILabel()
        plotLabel.numberOfLines = 0
        plotLabel.textColor = .black
        plotLabel.font = UIFont(name: "AvenirNext-Regular", size: 15) ?? UIFont.systemFont(ofSize: 15)
        return plotLabel
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
        collectionView.snp.updateConstraints { make in
            make.height.equalTo(self.collectionView.contentSize.height)
        }
        collectionView.layoutIfNeeded()
    }
    
    override func viewWillLayoutSubviews() {
       super.viewWillLayoutSubviews()
       collectionView.collectionViewLayout.invalidateLayout()
    }
    
    private func setView() {
        view.backgroundColor = .white
        navigationItem.largeTitleDisplayMode = .never
    }
    
    private func configureCollectionView() {
        snapshot.appendSections(DetailSection.allCases)
    }
    
    private func configureDataSource() {
        movieDetailDataSource = DataSource(collectionView: self.collectionView) { [weak self] collectionView, indexPath, itemIdentifier in
            self?.viewModel.updateReviewState(with: itemIdentifier)
            let cell = collectionView.dequeueReusableCell(withClass: MovieDetailReviewsCollectionViewCell.self, indexPath: indexPath)
            guard let reviews = self?.viewModel.reviews,
                  let review = reviews.filter({ $0.id == itemIdentifier }).first else {
                return MovieDetailReviewsCollectionViewCell()
            }
            cell.configure(with: review)

            return cell
        }
        
        self.movieDetailDataSource.supplementaryViewProvider = { [weak self] (collectionView, kind, indexPath) in
            let header = collectionView.dequeueReuseableSupplementaryView(withClass: MovieDetailHeaderView.self, indexPath: indexPath)
            let section = self?.movieDetailDataSource.snapshot().sectionIdentifiers[indexPath.section]
            header.label.text = section?.description
            return header
        }
    }
    
    private func applyReviewsSnapshot(reviews: [MovieDetailReview]) {
        let reviewsID = reviews.map { $0.id }
        snapshot.appendItems(reviewsID, toSection: DetailSection.review)
        self.movieDetailDataSource?.apply(snapshot)
    }

    private func configureBind() {
        ratingView.didFinishTouchingCosmos = { [weak self] rating in
            self?.ratingRelay.accept(rating)
            self?.ratingView.rating = rating
            self?.presentRatedAlert(with: rating)
        }
        
        let output = viewModel.transform(input)
        output.reviews
            .drive(with: self, onNext: { (self, reviews) in
                self.applyReviewsSnapshot(reviews: reviews)
                self.collectionView.snp.updateConstraints { make in
                    make.height.equalTo(self.collectionView.contentSize.height)
                }
            }).disposed(by: disposeBag)
        
        output.imageUrl
            .drive(with: self, onNext: { (self, url) in
                self.configureImageView(with: url)
            })
            .disposed(by: disposeBag)
        
        output.title
            .drive(titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.description
            .drive(descriptionLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.averageRating
            .drive(averageRatingLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.plot
            .drive(plotLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.myRating
            .drive(ratingView.rx.rating)
            .disposed(by: disposeBag)
        
        output.updateRating
            .compactMap { [weak self] rating in
                rating ? self?.ratingView.rating : 0
            }
            .drive(ratingView.rx.rating)
            .disposed(by: disposeBag)
    }
    
    private func presentRatedAlert(with rating: Double) {
        let alert = UIAlertController(title: "Successfully Rated", message: "\(rating)", preferredStyle: .alert)
        let confirm = UIAlertAction(title: "Okay", style: .default)
        alert.addAction(confirm)
        present(alert, animated: true)
    }
    
    private func configureImageView(with url: URL) {
        self.posterImageView.kf.setImage(
            with: url,
            placeholder: UIImage(),
            options: [
                .transition(.fade(1)),.forceTransition,
                .processor(DownsamplingImageProcessor(size: CGSize(width: 368, height: 500))),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage],
            completionHandler: nil
        )
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
        let descriptionStackView = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel, averageRatingLabel, ratingView])
        let plotStackView = UIStackView(arrangedSubviews: [plotTitleLabel, plotLabel])
        let entireStackView = UIStackView(arrangedSubviews: [posterImageView, descriptionStackView, plotStackView, collectionView])
        
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
            make.height.equalTo(500)
        }
        
        descriptionStackView.axis = .vertical
        descriptionStackView.alignment = .center
        descriptionStackView.distribution = .equalSpacing
        descriptionStackView.spacing = 10
        
        plotStackView.snp.makeConstraints { make in
            make.top.equalTo(descriptionStackView.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(13)
        }
        
        plotStackView.axis = .vertical
        plotStackView.alignment = .leading
        plotStackView.distribution = .equalSpacing
        plotStackView.spacing = 5
        
        collectionView.snp.makeConstraints { make in
            make.height.equalTo(10)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
}
