//
//  NotificationService.swift
//  TwitterPractice
//
//  Created by 강창혁 on 2022/10/24.
//

import Foundation
import FirebaseAuth

struct NotificationService {
    static let shared = NotificationService()
    func uploadNotification(toUser user: UserInfo,
                            type: NotificationType,
                            tweetID: String? = nil
                            ) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        var values: [String: Any] = ["timestamp": Int(NSDate().timeIntervalSince1970),
                                     "uid": uid,
                                     "type": type.rawValue]
        if let tweetID = tweetID {
            values["tweetID"] = tweetID
            
        }
        notificationRef.child(user.uid).childByAutoId().updateChildValues(values)
    }
    fileprivate func getNotifications(uid: String, completion: @escaping ([Notification]) -> Void ) {
        
        var notifications = [Notification]()
        
        notificationRef.child(uid).observe(.childAdded) { snapshot in
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            guard let uid = dictionary["uid"] as? String else { return }
            
            UserService.shared.fetchUser(uid: uid) { user in
                let notification = Notification(user: user, dictionary: dictionary)
                notifications.append(notification)
                completion(notifications)
            }
        }
    }
    
    func fetchNotification(completion: @escaping([Notification]) -> Void) {
        var notifications = [Notification]()
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        notificationRef.child(uid).observeSingleEvent(of: .value) { snapshot in
            if !snapshot.exists() {
                completion(notifications)
            } else {
                getNotifications(uid: uid, completion: completion)
            }
        }
    }
}
