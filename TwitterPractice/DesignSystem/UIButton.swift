//
//  UIButton+.swift
//  TwitterPractice
//
//  Created by KangChangHyeok on 8/4/24.
//

import UIKit

extension UIButton {
    
    func configure(imageName: String) {
        self.setImage(.init(named: imageName), for: .normal)
        self.tintColor = .darkGray
    }
    
    
}
