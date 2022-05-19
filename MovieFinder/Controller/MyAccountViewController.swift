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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
