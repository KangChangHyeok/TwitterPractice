//
//  Notification.swift
//  TwitterPractice
//
//  Created by 강창혁 on 2022/10/24.
//

import Foundation

enum NotificationType: Int {
    case follow
    case like
    case reply
    case retweet
    case mention
    
    var description: String {
        switch self {
        case .follow:
            return "Follow"
        case .like:
            return "Like"
        case .reply:
            return "Reply"
        case .retweet:
            return "Retweet"
        case .mention:
            return "Mention"
        }
    }
}
