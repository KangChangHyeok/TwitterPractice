//
//  DataBase.swift
//  TwitterPractice
//
//  Created by KangChangHyeok on 7/30/24.
//

import FirebaseCore
import FirebaseFirestore

final class NetworkManager {
    
    static let userCollection = Firestore.firestore().collection("Users")
    static let tweetCollection = Firestore.firestore().collection("Tweets")
    
    static func requestUser(userID: String) async throws -> User {
        try await Firestore.firestore().collection("Users").document(userID).getDocument(as: User.self)
    }
}
