//
//  ViewController.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/13.
//

import UIKit

class AuthenticationViewController: UIViewController {
    @IBOutlet weak var posterImage: UIImageView!
    let viewModel = AuthenticationViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        viewModel.search(with: "Avengers")
//        viewModel.getDetails(with: 271110) { result in
//            switch result {
//            case .success(let movieDetail):
//                self.viewModel.getOMDBDetails(with: movieDetail.imdbID!)
//                self.viewModel.getImage(with: movieDetail.posterPath!)
//                self.viewModel.getVideoId(with: movieDetail.id)
//            case .failure(let error):
//                if let error = error as? URLSessionError {
//                    print(error.errorDescription)
//                }
//
//                if let error = error as? JSONError {
//                    print("data decode failure: \(error.localizedDescription)")
//                }
//            }
//        }
//
//        viewModel.getReviews(with: 1771)
//        viewModel.createSession()
    }
    
    @IBAction func openURL(_ sender: Any) {
        viewModel.getToken()
    }
    
    @IBAction func createSessionID(_ sender: Any) {
        viewModel.createSession()
    }
}
