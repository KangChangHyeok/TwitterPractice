//
//  UserDefaults.swift
//  TwitterPractice
//
//  Created by KangChangHyeok on 7/30/24.
//

import Foundation

extension UserDefaults {
    
    static func userIsLogin() -> Bool {
        self.standard.bool(forKey: "userIsLogin")
    }
    
    static func fecthUserID() -> String? {
        self.standard.string(forKey: "userID")
    }
}
