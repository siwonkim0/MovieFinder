//
//  MovieListByTopicViewController.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/31.
//

import UIKit

class MovieListCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let viewModel: MovieListCollectionViewModel
    
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
        viewModel.getMovieListItem { items in
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    func registerCollectionViewCell() {
        self.collectionView.register(UINib(nibName: "MovieListCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MovieListCollectionViewCell")
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.backgroundColor = .blue
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.itemViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieListCollectionViewCell", for: indexPath) as! MovieListCollectionViewCell
        cell.configure(with: viewModel.itemViewModels[indexPath.row])
        
        return cell
    }
    
    func setLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 400, height: 400)

        collectionView?.setCollectionViewLayout(layout, animated: false)
    }


}
