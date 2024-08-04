//
//  Reusable.swift
//  TwitterPractice
//
//  Created by KangChangHyeok on 8/4/24.
//

import Foundation

protocol Reusable {
    static var reuseIdentifier: String { get }
}

extension Reusable {
    static var reuseIdentifier: String {
            return String(describing: self)
        }
}
