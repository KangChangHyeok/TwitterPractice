//
//  UICollectionView+.swift
//  TwitterPractice
//
//  Created by KangChangHyeok on 8/4/24.
//

import UIKit

public extension UICollectionView {
    
    func register<T: UICollectionViewCell>(_: T.Type) {
        register(T.self, forCellWithReuseIdentifier: T.reuseIdentifier)
    }
    
    func register<T: UICollectionReusableView>(kind: String, _: T.Type) {
        if case UICollectionView.elementKindSectionHeader = kind {
            register(
                T.self,
                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: T.reuseIdentifier
            )
        } else if case UICollectionView.elementKindSectionFooter = kind {
            register(
                T.self,
                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                withReuseIdentifier: T.reuseIdentifier
            )
        }
    }
    
    func cell<T: UICollectionViewCell>(_: T.Type, indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            print("DEBUG: cell이 정상적으로 생성되지 않았습니다. register 부분을 확인해야함")
            return T()
        }
        return cell
    }
    func supplementaryView<T: UICollectionReusableView>(_: T.Type, kind: String, indexPath: IndexPath) -> T {
        guard let view = dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            print("DEBUG: supplementaryView가 정상적으로 생성되지 않았습니다. register 부분을 확인해야함")
            return T()
        }
        return view
    }
}
