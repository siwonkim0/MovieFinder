//
//  MovieListByTopicViewController.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/31.
//

import UIKit

class MovieListCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var topicLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let viewModel = MovieListCollectionViewModel(defaultMoviesUseCase: DefaultMoviesUseCase(moviesRepository: DefaultMoviesRepository(apiManager: APIManager())))
    var movieListItems: [ListItem]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCollectionViewCell()
        topicLabel.text = "Trending Now"
        topicLabel.textColor = .black
        setLayout()
        viewModel.getPopular()
        viewModel.getNowPlaying { items in
            self.movieListItems = try! items.get()
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
        viewModel.getTopRated()
        viewModel.getUpcoming()
    }
    
    func registerCollectionViewCell() {
        self.collectionView.register(UINib(nibName: "MovieListCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MovieListCollectionViewCell")
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.backgroundColor = .blue
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let itemCount = movieListItems?.count else {
            return 0
        }
        return itemCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieListCollectionViewCell", for: indexPath) as! MovieListCollectionViewCell
        let item = movieListItems?[indexPath.row]
        cell.configure(posterPath: item?.posterPath, rating: item?.rating, title: item?.title, originalLanguage: item?.originalLanguage)
        
        return cell
    }
    
    func setLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 400, height: 400)

        collectionView?.setCollectionViewLayout(layout, animated: false)
    }


}
