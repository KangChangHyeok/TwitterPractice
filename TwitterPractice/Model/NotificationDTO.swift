//
//  NotificationDTO.swift
//  TwitterPractice
//
//  Created by kangChangHyeok on 03/04/2025.
//

import Foundation

struct NotificationDTO: Codable, Hashable {
    
    let id: String
    let tweetID: String
    let caption: String
    let type: String  // NotificationType의 description 값이 저장됨
    let timeStamp: Date
    let user: User
}
