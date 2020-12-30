//
//  Auth.swift
//  SimpleChat
//
//  Created by Lucas Bighi on 16/12/20.
//

import FirebaseAuth

struct Authentication {
    private static let auth = Auth.auth()
    
    static func addStateDidChangeListener(listener: @escaping(Auth, User?) -> Void) {
        auth.addStateDidChangeListener(listener)
    }
    
    static func requestToCreateUser(withEmail email: String, andPassword password: String) {
        present(alert("Create new user", "The requested user doesn`t exists.\nDo you want to create it?") {_ in
            self.auth.createUser(withEmail: email, password: password) { (result, error) in
                if let error = error {
                    print("Error creating user: \(error)")
                } else {
                    if result != nil {
                        self.usersRef.addDocument(data: ["email": email])
                    }
                }
            }
        }, animated: true)
    }
    
    
}
