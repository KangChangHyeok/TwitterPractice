//
//  Tweet.swift
//  TwitterPractice
//
//  Created by 강창혁 on 2022/10/11.
//

import Foundation

import FirebaseFirestore

struct TweetDTO: Codable, Hashable {
    let id: String
    let caption: String
    var likeUsers: [String]
    var likes: Int
    let retweets: [TweetDTO]?
    let timeStamp: Date
    var user: User
}
