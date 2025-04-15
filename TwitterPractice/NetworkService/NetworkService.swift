//
//  DataBase.swift
//  TwitterPractice
//
//  Created by KangChangHyeok on 7/30/24.
//

import FirebaseCore
import FirebaseFirestore

final class NetworkService {
    
    static let database = Firestore.firestore()
    
    static let userCollection = database.collection("Users")
    static let tweetCollection = database.collection("Tweets")
    static let notifications = database.collection("Notifications")
    static let chatRooms = database.collection("ChatRooms")
    static let messages = database.collection("Messages")
    
    static func fetchUser(userID: String) async throws -> User {
        try await Firestore.firestore().collection("Users").document(userID).getDocument(as: User.self)
    }
    
    static func fetchRetweets(retweetIDs: [String]) async throws -> [TweetDTO] {
        let retweets = try await withThrowingTaskGroup(of: TweetDTO.self) { group in
            var retweets: [TweetDTO] = []
            
            for retweetID in retweetIDs {
                group.addTask {
                    return try await NetworkService.tweetCollection.document(retweetID).getDocument().data(as: TweetDTO.self)
                }
            }
            
            for try await retweet in group {
                retweets.append(retweet)
            }
            return retweets
        }
        return retweets
    }
    
    // 채팅방 생성
    static func createChatRoom(for receiveUserID: String) async throws -> ChatRoom {
        let loginUserID = UserDefaults.fecthUserID()!
        let roomID = UUID().uuidString
        
        let loginUser = try await NetworkService.fetchUser(userID: loginUserID)
        let receiveUser = try await NetworkService.fetchUser(userID: receiveUserID)
        
        let chatRoom = ChatRoom(
            id: roomID,
            joinedUsers: [loginUser, receiveUser],
            messageIDs: [],
            lastMessage: nil,
            lastMessageTime: nil,
            createdAt: Date()
        )
        
        try NetworkService.chatRooms.document(roomID).setData(from: chatRoom)
        return chatRoom
    }
    
    // 메세지 보내기
    static func sendMessage(to roomID: String, content: String) async throws {
            let messageID = UUID().uuidString
            let loginUserID = UserDefaults.fecthUserID()!
            
            let message = Message(
                id: messageID,
                senderID: loginUserID,
                content: content,
                timeStamp: Date(),
                isRead: false
            )
            
        try NetworkService.messages.document(messageID).setData(from: message)
            
            // 채팅방의 마지막 메시지 업데이트
            try await NetworkService.chatRooms.document(roomID).updateData([
                "lastMessage": content,
                "lastMessageTime": Date()
            ])
        }
    
}
