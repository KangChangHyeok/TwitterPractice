//
//  ProfileHeaderViewModel.swift
//  TwitterPractice
//
//  Created by 강창혁 on 2022/10/12.
//

import UIKit

enum ProfileFilterOptions: Int, CaseIterable {
    case tweets
    case replies
    case likes
    var description: String {
        switch self {
        case .tweets:
            return "Tweets"
        case .replies:
            return "Tweets & Replies"
        case .likes:
            return "Likes"
        }
    }
}
