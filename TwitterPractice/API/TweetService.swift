//
//  TweetService.swift
//  TwitterPractice
//
//  Created by 강창혁 on 2022/10/10.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

struct TweetService {
    static let shared = TweetService()
    func uploadTweet(caption: String, type: UPloadTweetConfiguration, completion: @escaping(DatabaseCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        var values = ["uid": uid, "timestamp": Int(NSDate().timeIntervalSince1970),
                      "likes": 0,
                      "retweets": 0,
                      "caption": caption] as [String: Any]
        switch type {
        case .tweet:
            tweetsRef.childByAutoId().updateChildValues(values) { _, ref in
                guard let tweetID = ref.key else { return }
                userTweetsRef.child(uid).updateChildValues([tweetID: 1], withCompletionBlock: completion)
            }
        case .reply(let tweet):
            values["replyingTo"] = tweet.user.username
            tweetRepliesRef.child(tweet.tweetID).childByAutoId()
                .updateChildValues(values) { _, ref in
                    guard let replyKey = ref.key else { return }
                    userRepliesRef.child(uid).updateChildValues([tweet.tweetID: replyKey], withCompletionBlock: completion)
                }
        }
    }
    func fetchTweets(completion: @escaping([TweetInfo]) -> Void) {
        var tweets = [TweetInfo]()
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        userFollowingRef.child(currentUid).observe(.childAdded) { snapshot in
            let followingUid = snapshot.key
            
            userTweetsRef.child(followingUid).observe(.childAdded) { snapshot in
                let tweetID = snapshot.key
                
                self.fetchTweet(withTweetID: tweetID) { tweet in
                    tweets.append(tweet)
                    completion(tweets)
                }
            }
        }
        userTweetsRef.child(currentUid).observe(.childAdded) { snapshot in
            let tweetID = snapshot.key
            
            self.fetchTweet(withTweetID: tweetID) { tweet in
                tweets.append(tweet)
                completion(tweets)
            }
        }
    }
    func fetchTweets(forUser user: UserInfo, completion: @escaping([TweetInfo]) -> Void) {
        var tweets = [TweetInfo]()
        userTweetsRef.child(user.uid).observe(.childAdded) { snapshot in
            let tweetID = snapshot.key
            self.fetchTweet(withTweetID: tweetID) { tweet in
                tweets.append(tweet)
                completion(tweets)
            }
        }
    }
    
    func fetchTweet(withTweetID tweetID: String, completion: @escaping(TweetInfo) -> Void) {
        tweetsRef.child(tweetID).observeSingleEvent(of: .value) { snapshot in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let uid = dictionary["uid"] as? String else { return }
            UserService.shared.fetchUser(uid: uid) { user in
                let tweet = TweetInfo(user: user, tweetID: tweetID, dictionary: dictionary)
                completion(tweet)
            }
        }
    }
    
    func fetchReplies(forUser user: UserInfo, completion: @escaping([TweetInfo]) -> Void) {
        var replies = [TweetInfo]()
        
        userRepliesRef.child(user.uid).observe(.childAdded) { snapshot in
            let tweetKey = snapshot.key
            guard let replyKey = snapshot.value as? String else { return }
            tweetRepliesRef.child(tweetKey).child(replyKey).observeSingleEvent(of: .value) { snapshot in
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                guard let uid = dictionary["uid"] as? String else { return }
                let replyID = snapshot.key
                
                UserService.shared.fetchUser(uid: uid) { user in
                    let reply = TweetInfo(user: user, tweetID: replyID, dictionary: dictionary)
                    replies.append(reply)
                    completion(replies)
                }
            }
        }
    }
    func fetchReplies(fortweet tweet: TweetInfo, completion: @escaping([TweetInfo]) -> Void) {
        var tweets = [TweetInfo]()
        tweetRepliesRef.child(tweet.tweetID).observe(.childAdded) { snapshot in
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            guard let uid = dictionary["uid"] as? String else { return }
            let tweetID = snapshot.key
            UserService.shared.fetchUser(uid: uid) { user in
                let tweet = TweetInfo(user: user, tweetID: tweetID, dictionary: dictionary)
                tweets.append(tweet)
                completion(tweets)
            }
        }
    }
    
    func fetchLikes(forUser user: UserInfo, completion: @escaping([TweetInfo]) -> Void) {
        var tweets = [TweetInfo]()
        userLikesRef.child(user.uid).observe(.childAdded) { snapshot in
            let tweetID = snapshot.key
            self.fetchTweet(withTweetID: tweetID) { likedTweet in
                var tweet = likedTweet
                tweet.didLike = true
                tweets.append(tweet)
                completion(tweets)
            }
        }
    }
    func likeTweet(tweet: TweetInfo, completion: @escaping(DatabaseCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let likes = tweet.didLike ? tweet.likes - 1 : tweet.likes + 1
        tweetsRef.child(tweet.tweetID).child("likes").setValue(likes)
        if tweet.didLike {
            // unlike tweet
            userLikesRef.child(uid).child(tweet.tweetID).removeValue { _, _ in
                tweetLikesRef.child(tweet.tweetID).removeValue(completionBlock: completion)
            }
        } else {
            // like tweet
            userLikesRef.child(uid).updateChildValues([tweet.tweetID: 0]) { _, _ in
                tweetLikesRef.child(tweet.tweetID).updateChildValues([uid: 1], withCompletionBlock: completion)
            }
        }
    }
    func checkIfUserLikedTweet(_ tweet: TweetInfo, completion: @escaping(Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        userLikesRef.child(uid).child(tweet.tweetID).observeSingleEvent(of: .value) { snapshot in
            completion(snapshot.exists())
        }
    }
}
