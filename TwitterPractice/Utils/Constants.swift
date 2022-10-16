//
//  Constants.swift
//  TwitterPractice
//
//  Created by 강창혁 on 2022/10/07.
//

import FirebaseDatabase
import FirebaseStorage
let storageRef = Storage.storage().reference()
let storageProfileImages = storageRef.child("profile_images")

let databaseRef = Database.database().reference()
let userRef = databaseRef.child("users")
let tweetsRef = databaseRef.child("tweets")
let userTweetsRef = databaseRef.child("user_tweets")
let userFollowerRef = databaseRef.child("user_followers")
let userFollowingRef = databaseRef.child("user_following")
