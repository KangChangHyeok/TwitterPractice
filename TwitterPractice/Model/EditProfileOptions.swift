//
//  EditProfileOptions.swift
//  TwitterPractice
//
//  Created by KangChangHyeok on 3/30/25.
//

import Foundation

enum EditProfileOptions: Int, CaseIterable {
    case fullname
    case username
    case bio
    
    var description: String {
        switch self {
        case .username: return "Username"
        case .fullname: return "Name"
        case .bio: return "Bio"
        }
    }
}
