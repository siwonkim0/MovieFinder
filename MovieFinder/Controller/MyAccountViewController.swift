//
//  MyAccountViewController.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/05/19.
//

import UIKit

final class MyAccountViewController: UIViewController {
    let viewModel = MyAccountViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.getAccountDetails(sessionID: "23a5123518359f5a9d2bb715be90c4703cdc2bca")
    }
}
