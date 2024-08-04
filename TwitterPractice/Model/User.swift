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
    let fullName: String
    let userName: String
    let profileImage: Data
}
