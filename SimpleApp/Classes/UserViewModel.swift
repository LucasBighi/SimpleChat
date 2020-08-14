//
//  ChatsViewModel.swift
//  SimpleApp
//
//  Created by Lucas Marques Bighi on 14/08/20.
//  Copyright © 2020 Lucas Marques Bighi. All rights reserved.
//

import Foundation
import FirebaseAuth
import RxSwift
import RxCocoa

class UserViewModel {
    
    typealias completionHandler = (Result<AuthDataResult, FirebaseError>) -> ()
    var currentUser = BehaviorRelay<User?>(value: nil)
    
    init() {
        Auth.auth().addStateDidChangeListener { (auth, user) in
            self.currentUser.accept(user)
        }
    }
    
    func login(email: String, password: String, completion: @escaping completionHandler) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                completion(.failure(FirebaseError(error)))
            } else {
                if let result = result {
                    completion(.success(result))
                }
            }
        }
    }
    
    func createUser(email: String, password: String, completion: @escaping completionHandler) {
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                completion(.failure(FirebaseError(error)))
            }
            if let result = result {
                completion(.success(result))
            }
        }
    }
    
    func logout(completion: @escaping(Error?) -> ()) {
        do {
            try Auth.auth().signOut()
            completion(nil)
        } catch let error {
            completion(error)
        }
    }
}
