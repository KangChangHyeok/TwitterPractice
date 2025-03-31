//
//  ActionSheetViewModel.swift
//  TwitterPractice
//
//  Created by 강창혁 on 2022/10/24.
//

import UIKit

struct ActionSheetViewModel {
    private let user: User
    var options: [ActionSheetOptions] {
        var results = [ActionSheetOptions]()
        
        guard let userID = UserDefaults.fecthUserID() else { return [.blockUser] }
        if user.email == userID {
            results.append(.delete)
        } else {
//            let followOption: ActionSheetOptions = user.isFollowed ? .unfollow(user) : .follow(user)
//            results.append(followOption)
        }
        results.append(.report)
    return results
    }
    init(user: User) {
        self.user = user
    }
}

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
