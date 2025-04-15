//
//  NSAttributedString.swift
//  TwitterPractice
//
//  Created by 강창혁 on 2023/09/23.
//

import Foundation

extension AttributedString {
    
    mutating func attributedString(_ firstPart: String?, _ secondPart: String?) -> Self {
        guard let firstPart, let secondPart else { return AttributedString("nil") }
        var firstAttributedString = AttributedString(firstPart)
        firstAttributedString.font = .systemFont(ofSize: 16)
        firstAttributedString.foregroundColor = .white
        
        var secondAttributedString = AttributedString(secondPart)
        secondAttributedString.font = .boldSystemFont(ofSize: 16)
        secondAttributedString.foregroundColor = .white
        
        self = firstAttributedString + secondAttributedString
        return self
    }
}
