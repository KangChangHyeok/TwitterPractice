//
//  UIColor+.swift
//  TwitterPractice
//
//  Created by kangChangHyeok on 15/04/2025.
//

import UIKit

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    static let twitterBlue = UIColor.rgb(red: 29, green: 161, blue: 242)
}
