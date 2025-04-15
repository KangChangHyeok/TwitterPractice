//
//  ActionSheetOptions.swift
//  TwitterPractice
//
//  Created by 강창혁 on 2022/10/24.
//

import Foundation

enum ActionSheetOptions {
    case follow(User)
    case unfollow(User)
    case report
    case delete
    case blockUser
    var description: String {
        switch self {
        case .follow(let user):
            return "Follow @\(user.userName)"
        case .unfollow(let user):
            return "UnFollow @\(user.userName)"
        case .report:
            return "Report Tweet"
        case .delete:
            return "Delete Tweet"
        case .blockUser:
            return "Block User"
        }
    }
}
