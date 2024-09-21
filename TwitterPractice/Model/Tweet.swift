//
//  Tweet.swift
//  TwitterPractice
//
//  Created by 강창혁 on 2022/10/11.
//

import Foundation

import FirebaseFirestore

struct Tweet: Codable, Hashable {
    let id: String
    let caption: String
    var likeUsers: [String]
    var likes: Int
    let retweets: [Retweet]
    let timeStamp: Date
    var user: User
}


struct Retweet: Codable, Hashable {
    let user: User
    let id: String
    let caption: String
    var likeUsers: [String]
    var likes: Int
    let timeStamp: Date
}

struct TweetInfo {
    let caption: String
    let tweetID: String
    var likes: Int
    var timeStamp: Date!
    let retweetCount: Int
    var user: UserInfo
    var didLike = false
    var replyingTo: String?
    
    
    var isReply: Bool { return replyingTo != nil }
    
    init(user: UserInfo, tweetID: String, dictionary: [String: Any]) {
        self.tweetID = tweetID
        self.user = user
        
        self.caption = dictionary["caption"] as? String ?? ""
        self.likes = dictionary["likes"] as? Int ?? 0
        self.retweetCount = dictionary["retweets"] as? Int ?? 0
        if let timeStamp = dictionary["timestamp"] as? Double {
            self.timeStamp = Date(timeIntervalSince1970: timeStamp)
        }
        if let replyingTo = dictionary["replyingTo"] as? String {
            self.replyingTo = replyingTo
        }
    }
}
