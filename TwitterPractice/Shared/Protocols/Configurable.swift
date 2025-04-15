//
//  Configurable.swift
//  TwitterPractice
//
//  Created by KangChangHyeok on 3/31/25.
//

import Foundation


public protocol Configurable {}

public extension Configurable where Self: NSObject {
    func configure(configuration: (Self) -> Void) -> Self {
        configuration(self)
        return self
    }
}

extension NSObject: Configurable {}
