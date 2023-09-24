//
//  UIAlertController.swift
//  TwitterPractice
//
//  Created by 강창혁 on 2023/09/24.
//

import UIKit

extension UIAlertController {
    
    static func presentAlert(
        title: String?,
        messages: String?,
        _ self: UIViewController
    ) {
        let checkAction = UIAlertAction(title: "확인", style: .default)
        let alertController = UIAlertController(
            title: title,
            message: messages,
            preferredStyle: .alert
        )
        alertController.addAction(checkAction)
        self.present(alertController, animated: true)
    }
}
