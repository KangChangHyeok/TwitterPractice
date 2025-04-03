//
//  Tweet.swift
//  TwitterPractice
//
//  Created by 강창혁 on 2022/10/11.
//

import Foundation

import FirebaseFirestore

struct TweetDTO: Codable, Hashable {
    let originalTweetID: String
    let id: String
    let caption: String
    var likes: Int
    var likeUsers: [String]
    var retweetIDs: [String]
    let timeStamp: Date
    var user: User
}
