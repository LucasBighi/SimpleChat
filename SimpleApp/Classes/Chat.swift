//
//  Chat.swift
//  SimpleApp
//
//  Created by Lucas Marques Bighi on 14/08/20.
//  Copyright © 2020 Lucas Marques Bighi. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct Chat {
    
    let message: String
    let sender: String
    let time: String
    
    init?(snapshot: DocumentSnapshot?) {
        guard let dict = snapshot?.data(),
            let message = dict["message"] as? String,
            let sender = dict["sender"] as? String,
            let time = dict["time"] as? String else {
                return nil
        }
        
        self.message = message
        self.sender = sender
        self.time = time
    }
}
