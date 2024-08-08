//
//  UIAlertController.swift
//  TwitterPractice
//
//  Created by 강창혁 on 2023/09/24.
//
import SwiftUI
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


#if DEBUG
extension UIViewController {
    private struct Preview: UIViewControllerRepresentable {
        let viewController: UIViewController
        
        func makeUIViewController(context: Context) -> UIViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        }
    }
    
    func toPreview() -> some View {
        Preview(viewController: self)
    }
}
#endif
