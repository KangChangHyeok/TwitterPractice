//
//  ChatRoom.swift
//  TwitterPractice
//
//  Created by kangChangHyeok on 06/04/2025.
//

import Foundation

struct ChatRoom: Codable, Hashable {
    let id: String
    let joinedUsers: [User]
    let messageIDs: [String]
    let lastMessage: String?
    let lastMessageTime: Date?
    let createdAt: Date
}
