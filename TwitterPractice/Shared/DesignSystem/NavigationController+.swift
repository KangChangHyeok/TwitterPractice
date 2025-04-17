//
//  NavigationController+.swift
//  TwitterPractice
//
//  Created by kangChangHyeok on 16/04/2025.
//

import UIKit

extension UINavigationController {
    
    open override var childForStatusBarStyle: UIViewController? {
        return self.topViewController
    }
}
