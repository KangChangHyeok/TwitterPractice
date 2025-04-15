//
//  UITableView.swift
//  TwitterPractice
//
//  Created by KangChangHyeok on 8/4/24.
//

import UIKit

extension UITableView {
    
    func register<T: UITableViewCell>(_: T.Type) {
        register(T.self, forCellReuseIdentifier: T.reuseIdentifier)
    }
    
    func cell<T: UITableViewCell>(_: T.Type, indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            print("cell이 정상적으로 생성되지 않았습니다. register 부분을 확인해야함")
            return T()
        }
        return cell
    }
}
