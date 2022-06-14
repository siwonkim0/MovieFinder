//
//  ViewModelType.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/06/14.
//

import Foundation

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(_ input: Input) -> Output
}
