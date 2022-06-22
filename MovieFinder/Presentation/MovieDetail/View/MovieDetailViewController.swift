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
        case review(MovieDetailReview)
        case trailer(MovieDetailTrailer)
    }

    private enum DetailSection: Hashable, CaseIterable {
        case review
        case trailer
        
        var description: String {
            switch self {
            case .review:
                return "Comments"
            case .trailer:
                return "Trailers"
            }
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    private let viewModel: MovieDetailViewModel
    private let disposeBag = DisposeBag()
    private var movieListDataSource: DataSource!
    
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
        registerCollectionViewItems()
        configureDataSource()
        collectionView.setCollectionViewLayout(createLayout(), animated: true)
        configureBind()
    }
    
    private func registerCollectionViewItems() {
        self.collectionView.register(
            UINib(nibName: "MovieDetailCommentsCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "MovieDetailCommentsCollectionViewCell")
        self.collectionView.register(
            MovieDetailHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "MovieDetailHeaderView")
    }
    
    private func configureDataSource() {
        self.movieListDataSource = DataSource(collectionView: self.collectionView) { collectionView, indexPath, itemIdentifier in
        
            switch itemIdentifier {
            case .review(let review):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "MovieDetailCommentsCollectionViewCell",
                    for: indexPath) as? MovieDetailCommentsCollectionViewCell else {
                    return UICollectionViewCell()
                }
                print(review)
                cell.configure(with: review)
                return cell
            case .trailer(let trailer):
                return UICollectionViewCell()
            }
        }
        
        self.movieListDataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) in
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: "MovieDetailHeaderView",
                for: indexPath) as? MovieDetailHeaderView else {
                return MovieDetailHeaderView()
            }

            let section = self.movieListDataSource.snapshot().sectionIdentifiers[indexPath.section]
            if section == .review {
                header.label.text = section.description
            }
            return header
        }
    }
    
    private func applySnapshot(reviews: [MovieDetailReview]) {
        var snapshot = Snapshot()
        let sections = DetailSection.allCases
        snapshot.appendSections(sections)
        let movieReviews = reviews.map {
            MovieDetailItem.review($0)
        }
        snapshot.appendItems(movieReviews, toSection: DetailSection.review)
        self.movieListDataSource?.apply(snapshot)
    }
    
    func configureBind() {
        let output = viewModel.transform(MovieDetailViewModel.Input(viewWillAppear: self.rx.viewWillAppear.asObservable()))
        output.reviewsObservable
            .withUnretained(self)
            .subscribe(onNext: { (self,reviews) in
                self.applySnapshot(reviews: reviews)
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
