//
//  Message.swift
//  TwitterPractice
//
//  Created by kangChangHyeok on 06/04/2025.
//

import Foundation

struct Message: Codable, Hashable {
    let id: String
    let senderID: String
    let content: String
    let timeStamp: Date
    let isRead: Bool
}
