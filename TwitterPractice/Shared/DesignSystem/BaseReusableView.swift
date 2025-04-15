//
//  BaseReusableView.swift
//  TwitterPractice
//
//  Created by KangChangHyeok on 9/21/24.
//

import UIKit

class BaseReusableView: UICollectionReusableView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupDefaults()
        setupHierarchy()
        setupLayout()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func setupDefaults() {}
    
    open func setupHierarchy() {}
    
    open func setupLayout() {}
}
