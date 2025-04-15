//
//  Screen.swift
//  TwitterPractice
//
//  Created by 강창혁 on 2022/10/04.
//

import UIKit

struct Screen {
    static let scenes = UIApplication.shared.connectedScenes
    static let windowScene = scenes.first as? UIWindowScene
    static let window = windowScene?.windows.first
}
