//
//  RegisterViewModel.swift
//  TwitterPractice
//
//  Created by 강창혁 on 2022/11/05.
//

import Foundation
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class RegisterViewModel {
 
    func registerUser(credentials: AuthCredentials, completion: @escaping (Error?, DatabaseReference) -> Void) {
        AuthService.shared.registerUser(credentials: credentials) { err, ref in
            completion(err, ref)
        }
    }
}
