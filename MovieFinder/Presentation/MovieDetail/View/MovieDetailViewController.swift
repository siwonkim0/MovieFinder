//
//  MovieDetailViewController.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/19.
//

import UIKit
import RxSwift
import Kingfisher

final class MovieDetailViewController: UIViewController {
    private enum MovieDetailItem: Hashable {
        case plotSummary(MovieDetailBasicInfo)
        case review(MovieDetailReview)
        case trailer(MovieDetailTrailer)
    }

    private enum DetailSection: Hashable, CaseIterable {
        case plotSummary
        case review
        case trailer
        
        var description: String {
            switch self {
            case .plotSummary:
                return "Plot Summary"
            case .review:
                return "Comments"
            case .trailer:
                return "Trailers"
            }
        }
    }
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var releaseYearLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var runtimeLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    
    private let viewModel: MovieDetailViewModel
    private let disposeBag = DisposeBag()
    private var movieListDataSource: DataSource!
    private var snapshot = Snapshot()
    
    private typealias DataSource = UICollectionViewDiffableDataSource<DetailSection, MovieDetailItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<DetailSection, MovieDetailItem>
    
    init?(viewModel: MovieDetailViewModel, coder: NSCoder) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        self.collectionView.backgroundColor = .black
        navigationItem.largeTitleDisplayMode = .never
        configureCollectionView()
        configureDataSource()
        configureBind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionViewHeight.constant = collectionView.contentSize.height - 400
        collectionView.layoutIfNeeded()
    }
    
    private func configureCollectionView() {
        self.collectionView.registerCell(withNib: MovieDetailCommentsCollectionViewCell.self)
        self.collectionView.registerCell(withNib: PlotSummaryCollectionViewCell.self)
        self.collectionView.registerSupplementaryView(withClass: MovieDetailHeaderView.self)
        collectionView.setCollectionViewLayout(createLayout(), animated: true)
        snapshot.appendSections(DetailSection.allCases)
    }
    
    private func configureDataSource() {
        self.movieListDataSource = DataSource(collectionView: self.collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .plotSummary(let basicInfo):
                let cell = collectionView.dequeueReusableCell(withClass: PlotSummaryCollectionViewCell.self, indexPath: indexPath)
                cell.configure(with: basicInfo)
                return cell
            case .review(let review):
                let cell = collectionView.dequeueReusableCell(withClass: MovieDetailCommentsCollectionViewCell.self, indexPath: indexPath)
                cell.configure(with: review)
                return cell
            case .trailer(let trailer):
                return UICollectionViewCell()
            }
        }
        
        self.movieListDataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) in
            let header = collectionView.dequeueReuseableSupplementaryView(withClass: MovieDetailHeaderView.self, indexPath: indexPath)
            let section = self.movieListDataSource.snapshot().sectionIdentifiers[indexPath.section]
            header.label.text = section.description
            return header
        }
    }
    
    private func applyPlotSummarySnapshot(with basicInfo: MovieDetailBasicInfo) {
        let basicInfo = MovieDetailItem.plotSummary(basicInfo)
        snapshot.appendItems([basicInfo], toSection: DetailSection.plotSummary)
        self.movieListDataSource?.apply(snapshot)
    }
    
    private func applyCommentsSnapshot(comments: [MovieDetailReview]) {
        let movieReviews = comments.map {
            MovieDetailItem.review($0)
        }
        snapshot.appendItems(movieReviews, toSection: DetailSection.review)
        self.movieListDataSource?.apply(snapshot)
    }
    
    private func configureBind() {
        let output = viewModel.transform(MovieDetailViewModel.Input(viewWillAppear: self.rx.viewWillAppear.asObservable()))
        output.reviewsObservable
            .observe(on: MainScheduler.instance)
            .take(1)
            .withUnretained(self)
            .subscribe(onNext: { (self, comments) in
                self.applyCommentsSnapshot(comments: comments)
            }).disposed(by: disposeBag)
        output.basicInfoObservable
            .observe(on: MainScheduler.instance)
            .take(1)
            .withUnretained(self)
            .subscribe(onNext: { (self, basicInfo) in
                guard let posterPath = basicInfo.posterPath,
                      let url = MovieURL.image(posterPath: posterPath).url else {
                    return
                }
                self.configureImageView(with: url)
                self.titleLabel.text = basicInfo.title
                self.releaseYearLabel.text = basicInfo.year
                self.genreLabel.text = basicInfo.genre
                self.runtimeLabel.text = basicInfo.runtime
                self.applyPlotSummarySnapshot(with: basicInfo)
            }).disposed(by: disposeBag)
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
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
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
            case .trailer:
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
                section.orthogonalScrollingBehavior = .groupPagingCentered
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
