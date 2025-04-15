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
        view.backgroundColor = .white
        setupDefaults()
        setupHierarchy()
        setupLayout()
    }
    
    open func setupDefaults() {}
    
    open func setupHierarchy() {}
    
    open func setupLayout() {}
    
    deinit {
        print("❗️\(String(describing: self)) deinit")
    }
}
