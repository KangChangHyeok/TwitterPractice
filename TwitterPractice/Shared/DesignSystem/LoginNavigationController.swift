//
//  LoginNavigationController.swift
//  TwitterPractice
//
//  Created by kangChangHyeok on 18/04/2025.
//

import UIKit

final class LoginNavigationController: UINavigationController {
    
    override var childForStatusBarStyle: UIViewController? {
        return self.topViewController
    }
}
