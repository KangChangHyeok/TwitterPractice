//
//  ProfileHeaderViewModel.swift
//  TwitterPractice
//
//  Created by 강창혁 on 2022/10/12.
//

import Foundation

enum ProfileFilterOptions: Int, CaseIterable {
    case tweets
    case replies
    case likes
    var description: String {
        switch self {
        case .tweets:
            return "트윗"
        case .replies:
            return "리트윗"
        case .likes:
            return "좋아요"
        }
    }
}
