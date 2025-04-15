//
//  TwitterUser.swift
//  TwitterPractice
//
//  Created by KangChangHyeok on 7/30/24.
//

import Foundation

struct User: Codable, Hashable {
    
    let email: String
    let password: String
    var fullName: String
    var userName: String
    var profileImage: Data
    var follow: [String]
    var following: [String]
}
