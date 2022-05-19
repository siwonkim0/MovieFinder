//
//  MovieDetailViewController.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/19.
//

import UIKit

class MovieDetailViewController: UIViewController {
    let viewModel = MovieDetailViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.getDetails(with: 271110) { result in
            switch result {
            case .success(let movieDetail):
                self.viewModel.getOMDBDetails(with: movieDetail.imdbID!)
                self.viewModel.getImage(with: movieDetail.posterPath!)
                self.viewModel.getVideoId(with: movieDetail.id)
            case .failure(let error):
                if let error = error as? URLSessionError {
                    print(error.errorDescription)
                }
                
                if let error = error as? JSONError {
                    print("data decode failure: \(error.localizedDescription)")
                }
            }
        }
        
        viewModel.getReviews(with: 1771)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
