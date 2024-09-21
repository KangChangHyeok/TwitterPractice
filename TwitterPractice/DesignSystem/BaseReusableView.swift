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
        setDefaults(at: self)
        setHierarchy(at: self)
        setLayout(at: self)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func setDefaults(at view: UIView) {}
    
    open func setHierarchy(at view: UIView) {}
    
    open func setLayout(at view: UIView) {}
}
