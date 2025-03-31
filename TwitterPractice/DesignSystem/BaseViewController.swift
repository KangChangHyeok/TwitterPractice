//
//  BaseViewController.swift
//  TwitterPractice
//
//  Created by KangChangHyeok on 8/3/24.
//

import UIKit

open class BaseViewController: UIViewController {
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupDefaults(at: self)
        setupHierarchy(at: self.view)
        setupLayout(at: self.view)
    }
    
    open func setupDefaults(at viewController: UIViewController) {}
    
    open func setupHierarchy(at view: UIView) {}
    
    open func setupLayout(at view: UIView) {}
    
    deinit {
        print("❗️\(String(describing: self)) deinit")
    }
}
