//
//  ActionSheetViewModel.swift
//  TwitterPractice
//
//  Created by 강창혁 on 2022/10/24.
//

import UIKit

struct ActionSheetViewModel {
    private let user: UserInfo
    var options: [ActionSheetOptions] {
        var results = [ActionSheetOptions]()
        if user.isCurrentUser {
            results.append(.delete)
        } else {
            let followOption: ActionSheetOptions = user.isFollowed ? .unfollow(user) : .follow(user)
            results.append(followOption)
        }
        results.append(.report)
    return results
    }
    init(user: UserInfo) {
        self.user = user
    }
}

enum ActionSheetOptions {
    case follow(UserInfo)
    case unfollow(UserInfo)
    case report
    case delete
    case blockUser
    var description: String {
        switch self {
        case .follow(let user):
            return "Follow @\(user.username)"
        case .unfollow(let user):
            return "UnFollow @\(user.username)"
        case .report:
            return "Report Tweet"
        case .delete:
            return "Delete Tweet"
        case .blockUser:
            return "Block User"
        }
    }
}
