//
//  MovieDetailViewController.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/19.
//

import UIKit
import RxSwift

class MovieDetailViewController: UIViewController {
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
    
    @IBOutlet weak var posterImageView: DownloadableUIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var releaseYearLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var runtimeLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
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
        navigationItem.largeTitleDisplayMode = .never
        configureCollectionView()
        configureDataSource()
        configureBind()
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
    
    func configureBind() {
        let output = viewModel.transform(MovieDetailViewModel.Input(viewWillAppear: self.rx.viewWillAppear.asObservable()))
        output.reviewsObservable
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { (self, comments) in
                self.applyCommentsSnapshot(comments: comments)
            }).disposed(by: disposeBag)
        output.basicInfoObservable
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { (self, basicInfo) in
                guard let posterPath = basicInfo.posterPath,
                      let url = MovieURL.image(posterPath: posterPath).url else {
                    return
                }
                self.posterImageView.getImage(with: url)
                self.titleLabel.text = basicInfo.title
                self.releaseYearLabel.text = basicInfo.year
                self.genreLabel.text = basicInfo.genre
                self.runtimeLabel.text = basicInfo.runtime
                self.applyPlotSummarySnapshot(with: basicInfo)
            }).disposed(by: disposeBag)
    }
    
    func createLayout() -> UICollectionViewLayout {
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
        section.decorationItems = [
            NSCollectionLayoutDecorationItem.background(elementKind: "background-element-kind")
        ]
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)
        section.boundarySupplementaryItems = [sectionHeader]
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        layout.register(SectionBackgroundDecorationView.self, forDecorationViewOfKind: "background-element-kind")
        return layout
    }
}
