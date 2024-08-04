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
        setDefaults(at: self)
        setHierarchy(at: self.view)
        setLayout(at: self.view)
    }
    
    open func setDefaults(at viewController: UIViewController) {}
    
    open func setHierarchy(at view: UIView) {}
    
    open func setLayout(at view: UIView) {}
    
    deinit {
        print("❗️\(String(describing: self)) deinit")
    }
}
