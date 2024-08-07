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


class LikeButton: UIButton {
    
    init() {
        super.init(frame: .zero)
        self.setImage(UIImage(named: "like")?.withTintColor(.darkGray, renderingMode: .alwaysOriginal), for: .normal)
        self.setImage(UIImage(named: "like_filled")?.withTintColor(.red, renderingMode: .alwaysOriginal), for: .selected)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
