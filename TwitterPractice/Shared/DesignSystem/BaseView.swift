//
//  BaseView.swift
//  TwitterPractice
//
//  Created by KangChangHyeok on 8/4/24.
//

import UIKit

open class BaseView: UIView {
    
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
