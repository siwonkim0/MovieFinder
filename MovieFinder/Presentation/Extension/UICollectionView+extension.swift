//
//  UICollectionView+extension.swift
//  MovieFinder
//
//  Created by Siwon Kim on 2022/06/22.
//

import UIKit

extension UICollectionView {
    func dequeueReusableCell<T: UICollectionViewCell>(
        withClass: T.Type,
        indexPath: IndexPath
) -> T {
        guard let cell = self.dequeueReusableCell(
            withReuseIdentifier: String(describing: T.self),
            for: indexPath
        ) as? T else {
            return T()
        }

        return cell
    }
    
    func dequeueReuseableSupplementaryView<T: UICollectionReusableView>(
        withClass: T.Type,
        indexPath: IndexPath
    ) -> T {
        guard let header = self.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: String(describing: T.self),
            for: indexPath
        ) as? T else {
            return T()
        }
        return header
    }

    func registerCell<T: UICollectionViewCell>(withClass: T.Type) {
        self.register(
            T.self,
            forCellWithReuseIdentifier: String(describing: T.self)
        )
    }
    
    func registerCell<T: UICollectionViewCell>(withNib: T.Type) {
        self.register(
            UINib(nibName: String(describing: T.self), bundle: nil),
            forCellWithReuseIdentifier: String(describing: T.self))
    }

    func registerSupplementaryView<T: UICollectionReusableView>(withClass: T.Type) {
        self.register(
            T.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: String(describing: T.self)
        )
    }

}
