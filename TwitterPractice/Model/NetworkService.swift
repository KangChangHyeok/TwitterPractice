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
}
